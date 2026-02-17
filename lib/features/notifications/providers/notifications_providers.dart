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
    return _defaultAudienceForRole(role, isWeb: kIsWeb);
  }

  void setAudience(CamAudience audience) {
    final allowed = ref.read(allowedAudiencesProvider);
    if (!allowed.contains(audience)) return;
    state = audience;
  }
}

final activeAudienceProvider =
    NotifierProvider<ActiveAudienceController, CamAudience>(
      ActiveAudienceController.new,
    );

final allowedAudiencesProvider = Provider<Set<CamAudience>>((ref) {
  final role = ref.watch(currentRoleProvider);
  return _allowedAudiencesForRole(role, isWeb: kIsWeb);
});

final availableAudiencesProvider = Provider<List<CamAudience>>((ref) {
  final allowed = ref.watch(allowedAudiencesProvider);
  const order = <CamAudience>[
    CamAudience.public,
    CamAudience.voter,
    CamAudience.observer,
    CamAudience.admin,
  ];
  return [
    for (final audience in order)
      if (allowed.contains(audience)) audience,
  ];
});

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
    Future<void>.microtask(_bootstrap);
    _startPolling();
    return const NotificationsState(loading: true, items: []);
  }

  Future<void> _bootstrap() async {
    state = state.copyWith(loading: true);
    try {
      await _refreshScopeIfNeeded(force: true);
    } catch (_) {
      // Keep the app usable even if bootstrap fails on corrupted local state.
    } finally {
      state = state.copyWith(loading: false);
    }
    // Fetch server updates in background so empty states do not spin forever.
    unawaited(syncFromServer());
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

    List<CamNotification> cached = const [];
    try {
      cached = await _repo.loadAll(scopeKey: _scopeKey);
    } catch (_) {
      cached = const [];
    }
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
      final response = await _workerClient
          .get(
            '/v1/notifications',
            queryParameters: queryParameters.isEmpty ? null : queryParameters,
          )
          .timeout(const Duration(seconds: 8));
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
    } catch (_) {
      // Fail open for non-network parsing/runtime issues.
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
    try {
      await _repo.saveAll(updated, scopeKey: _scopeKey);
    } catch (_) {
      // Ignore local cache write failures.
    }
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
    try {
      await _repo.saveAll(updated, scopeKey: _scopeKey);
    } catch (_) {
      // Ignore local cache write failures.
    }
    if (_isAuthenticated()) {
      unawaited(
        _workerClient.post(
          '/v1/notifications/mark-read',
          data: {'notificationId': id},
          allowOfflineQueue: true,
          queueType: 'notification_mark_read',
        ),
      );
    }
  }

  Future<void> markAllRead() async {
    final updated = state.items.map((n) => n.copyWith(read: true)).toList();
    state = state.copyWith(items: updated);
    try {
      await _repo.saveAll(updated, scopeKey: _scopeKey);
    } catch (_) {
      // Ignore local cache write failures.
    }
    if (_isAuthenticated()) {
      unawaited(
        _workerClient.post(
          '/v1/notifications/mark-all-read',
          allowOfflineQueue: true,
          queueType: 'notification_mark_all_read',
        ),
      );
    }
  }

  Future<void> remove(String id) async {
    final updated = state.items.where((n) => n.id != id).toList();
    state = state.copyWith(items: updated);
    try {
      await _repo.saveAll(updated, scopeKey: _scopeKey);
    } catch (_) {
      // Ignore local cache write failures.
    }
  }

  Future<void> clearAll() async {
    state = state.copyWith(items: const []);
    try {
      await _repo.saveAll(const [], scopeKey: _scopeKey);
    } catch (_) {
      // Ignore local cache write failures.
    }
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );

final filteredNotificationsProvider = Provider<List<CamNotification>>((ref) {
  final state = ref.watch(notificationsControllerProvider);
  final selectedAudience = ref.watch(activeAudienceProvider);
  final allowedAudiences = ref.watch(allowedAudiencesProvider);
  final role = ref.watch(currentRoleProvider);
  final fallbackAudience = _defaultAudienceForRole(role, isWeb: kIsWeb);
  final audience = allowedAudiences.contains(selectedAudience)
      ? selectedAudience
      : fallbackAudience;

  bool allowed(CamNotification n) {
    if (n.audience == CamAudience.all) return true;
    if (!allowedAudiences.contains(n.audience)) return false;
    if (n.audience == CamAudience.public) return true;
    return n.audience == audience;
  }

  return state.items.where(allowed).toList();
});

Set<CamAudience> _allowedAudiencesForRole(AppRole role, {required bool isWeb}) {
  return switch (role) {
    AppRole.admin => {CamAudience.admin},
    AppRole.voter => {CamAudience.public, CamAudience.voter},
    AppRole.observer => {CamAudience.public, CamAudience.observer},
    AppRole.public =>
      isWeb ? {CamAudience.public, CamAudience.observer} : {CamAudience.public},
  };
}

CamAudience _defaultAudienceForRole(AppRole role, {required bool isWeb}) {
  return switch (role) {
    AppRole.admin => CamAudience.admin,
    AppRole.voter => CamAudience.voter,
    AppRole.observer => CamAudience.observer,
    AppRole.public => isWeb ? CamAudience.observer : CamAudience.public,
  };
}
