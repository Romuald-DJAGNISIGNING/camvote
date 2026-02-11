import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/worker_client.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/theme/role_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/notifications_repository.dart';
import '../domain/cam_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository();
});

class ActiveAudienceController extends Notifier<CamAudience> {
  @override
  CamAudience build() {
    final role = ref.watch(currentRoleProvider);
    return switch (role) {
      AppRole.public => CamAudience.public,
      AppRole.voter => CamAudience.voter,
      AppRole.observer => CamAudience.observer,
      AppRole.admin => CamAudience.admin,
    };
  }

  void setAudience(CamAudience audience) => state = audience;
}

final activeAudienceProvider =
    NotifierProvider<ActiveAudienceController, CamAudience>(
      ActiveAudienceController.new,
    );

@immutable
class NotificationsState {
  final bool loading;
  final List<CamNotification> items;

  const NotificationsState({required this.loading, required this.items});

  int get unreadCount => items.where((n) => !n.read).length;

  NotificationsState copyWith({bool? loading, List<CamNotification>? items}) {
    return NotificationsState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
    );
  }
}

class NotificationsController extends Notifier<NotificationsState> {
  late final NotificationsRepository _repo;
  late final WorkerClient _workerClient;
  Timer? _pollTimer;
  String _scopeKey = 'guest';
  DateTime? _lastRemoteSyncAt;
  bool _syncInFlight = false;

  @override
  NotificationsState build() {
    _repo = ref.watch(notificationsRepositoryProvider);
    _workerClient = ref.watch(workerClientProvider);
    ref.onDispose(() => _pollTimer?.cancel());
    unawaited(_bootstrap());
    _startPolling();
    return const NotificationsState(loading: true, items: []);
  }

  Future<void> _bootstrap() async {
    state = state.copyWith(loading: true);
    await _refreshScopeIfNeeded(force: true);
    state = state.copyWith(loading: false);
    await syncFromServer();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      unawaited(syncFromServer());
    });
  }

  String _currentScopeKey() {
    final auth = ref.read(authControllerProvider).asData?.value;
    final userId = auth?.user?.id.trim() ?? '';
    return userId.isEmpty ? 'guest' : userId;
  }

  bool _isAuthenticated() {
    final auth = ref.read(authControllerProvider).asData?.value;
    return auth?.isAuthenticated == true;
  }

  Future<void> _refreshScopeIfNeeded({bool force = false}) async {
    final nextScope = _currentScopeKey();
    if (!force && nextScope == _scopeKey) return;
    _scopeKey = nextScope;

    final cached = await _repo.loadAll(scopeKey: _scopeKey);
    _lastRemoteSyncAt = _maxCreatedAt(cached);
    state = NotificationsState(loading: false, items: cached);
  }

  DateTime? _maxCreatedAt(List<CamNotification> items) {
    DateTime? max;
    for (final item in items) {
      if (max == null || item.createdAt.isAfter(max)) {
        max = item.createdAt;
      }
    }
    return max;
  }

  CamNotificationType _parseType(String raw) {
    final normalized = raw.trim().toLowerCase();
    return CamNotificationType.values.firstWhere(
      (value) => value.name == normalized,
      orElse: () => CamNotificationType.info,
    );
  }

  CamAudience _parseAudience(String raw) {
    final normalized = raw.trim().toLowerCase();
    return CamAudience.values.firstWhere(
      (value) => value.name == normalized,
      orElse: () => CamAudience.public,
    );
  }

  List<CamNotification> _mergeNotifications(
    List<CamNotification> existing,
    List<CamNotification> incoming,
  ) {
    final byId = <String, CamNotification>{
      for (final item in existing) item.id: item,
    };
    for (final item in incoming) {
      final previous = byId[item.id];
      if (previous != null && previous.read && !item.read) {
        byId[item.id] = item.copyWith(read: true);
      } else {
        byId[item.id] = item;
      }
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  Future<void> syncFromServer() async {
    if (_syncInFlight) return;
    _syncInFlight = true;
    try {
      await _refreshScopeIfNeeded();
      if (!_isAuthenticated()) return;

      final queryParameters = <String, dynamic>{
        if (_lastRemoteSyncAt != null)
          'since': _lastRemoteSyncAt!.toUtc().toIso8601String(),
      };
      final response = await _workerClient.get(
        '/v1/notifications',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final raw = response['notifications'];
      if (raw is! List || raw.isEmpty) return;

      final incoming = raw.whereType<Map>().map((item) {
        final map = item.cast<String, dynamic>();
        final createdAt =
            DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now();
        return CamNotification(
          id: map['id']?.toString() ?? UniqueKey().toString(),
          type: _parseType(map['type']?.toString() ?? ''),
          audience: _parseAudience(map['audience']?.toString() ?? ''),
          title: map['title']?.toString() ?? '',
          body: map['body']?.toString() ?? '',
          createdAt: createdAt,
          read: map['read'] == true,
          route: map['route']?.toString(),
        );
      }).toList();
      if (incoming.isEmpty) return;

      final previousById = {for (final item in state.items) item.id: item};
      final newUnread = incoming.where(
        (item) => !item.read && !previousById.containsKey(item.id),
      );

      final merged = _mergeNotifications(state.items, incoming);
      state = state.copyWith(items: merged, loading: false);
      await _repo.saveAll(merged, scopeKey: _scopeKey);
      _lastRemoteSyncAt = _maxCreatedAt(merged);

      for (final item in newUnread) {
        await LocalNotificationsService.instance.showNow(
          id: item.createdAt.millisecondsSinceEpoch.remainder(1000000),
          title: item.title,
          body: item.body,
        );
      }
    } on WorkerException {
      // Keep local notifications available if server sync fails.
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> add({
    required CamNotificationType type,
    required CamAudience audience,
    required String title,
    required String body,
    String? route,
    String? id,
    bool alsoPush = true,
  }) async {
    final item = CamNotification(
      id: id?.trim().isNotEmpty == true ? id!.trim() : UniqueKey().toString(),
      type: type,
      audience: audience,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      read: false,
      route: route,
    );

    final updated = [item, ...state.items];
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated, scopeKey: _scopeKey);
    _lastRemoteSyncAt = _maxCreatedAt(updated);

    if (alsoPush) {
      await LocalNotificationsService.instance.showNow(
        id: item.createdAt.millisecondsSinceEpoch.remainder(1000000),
        title: title,
        body: body,
      );
    }
  }

  Future<void> markRead(String id) async {
    final updated = state.items
        .map((n) => n.id == id ? n.copyWith(read: true) : n)
        .toList();
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated, scopeKey: _scopeKey);
    if (_isAuthenticated()) {
      unawaited(
        _workerClient.post(
          '/v1/notifications/mark-read',
          data: {'notificationId': id},
        ),
      );
    }
  }

  Future<void> markAllRead() async {
    final updated = state.items.map((n) => n.copyWith(read: true)).toList();
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated, scopeKey: _scopeKey);
    if (_isAuthenticated()) {
      unawaited(_workerClient.post('/v1/notifications/mark-all-read'));
    }
  }

  Future<void> remove(String id) async {
    final updated = state.items.where((n) => n.id != id).toList();
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated, scopeKey: _scopeKey);
  }

  Future<void> clearAll() async {
    state = state.copyWith(items: const []);
    await _repo.saveAll(const [], scopeKey: _scopeKey);
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );

final filteredNotificationsProvider = Provider<List<CamNotification>>((ref) {
  final state = ref.watch(notificationsControllerProvider);
  final audience = ref.watch(activeAudienceProvider);

  bool allowed(CamNotification n) {
    if (n.audience == CamAudience.all) return true;
    if (n.audience == CamAudience.public) return true;
    return n.audience == audience;
  }

  return state.items.where(allowed).toList();
});
