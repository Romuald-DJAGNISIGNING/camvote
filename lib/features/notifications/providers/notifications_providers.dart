import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/local_notifications_service.dart';
import '../data/notifications_repository.dart';
import '../domain/cam_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository();
});

/// Current app “mode/role” for filtering.
/// ✅ Connect this to your real role provider later in ONE place.
/// For now it’s a simple override state.
class ActiveAudienceController extends Notifier<CamAudience> {
  @override
  CamAudience build() => CamAudience.public;

  void setAudience(CamAudience audience) => state = audience;
}

final activeAudienceProvider =
    NotifierProvider<ActiveAudienceController, CamAudience>(ActiveAudienceController.new);

@immutable
class NotificationsState {
  final bool loading;
  final List<CamNotification> items;

  const NotificationsState({
    required this.loading,
    required this.items,
  });

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

  @override
  NotificationsState build() {
    _repo = ref.watch(notificationsRepositoryProvider);
    _bootstrap();
    return const NotificationsState(loading: true, items: []);
  }

  Future<void> _bootstrap() async {
    state = state.copyWith(loading: true);
    final items = await _repo.loadAll();
    state = NotificationsState(loading: false, items: items);
  }

  Future<void> add({
    required CamNotificationType type,
    required CamAudience audience,
    required String title,
    required String body,
    String? route,
    bool alsoPush = true,
  }) async {
    final item = CamNotification(
      id: UniqueKey().toString(),
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
    await _repo.saveAll(updated);

    // OS push (Android/iOS) — works now
    if (alsoPush) {
      await LocalNotificationsService.instance.showNow(
        id: item.createdAt.millisecondsSinceEpoch.remainder(1000000),
        title: title,
        body: body,
      );
    }
  }

  Future<void> markRead(String id) async {
    final updated = state.items.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated);
  }

  Future<void> markAllRead() async {
    final updated = state.items.map((n) => n.copyWith(read: true)).toList();
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated);
  }

  Future<void> remove(String id) async {
    final updated = state.items.where((n) => n.id != id).toList();
    state = state.copyWith(items: updated);
    await _repo.saveAll(updated);
  }

  Future<void> clearAll() async {
    state = state.copyWith(items: const []);
    await _repo.saveAll(const []);
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(NotificationsController.new);

/// Filtered list for the current role/mode.
/// - public sees: public + all
/// - voter sees: voter + all + public (since public features are allowed too)
/// - admin sees: admin + all + public
/// - observer sees: observer + all + public
final filteredNotificationsProvider = Provider<List<CamNotification>>((ref) {
  final state = ref.watch(notificationsControllerProvider);
  final audience = ref.watch(activeAudienceProvider);

  bool allowed(CamNotification n) {
    if (n.audience == CamAudience.all) return true;
    if (n.audience == CamAudience.public) return true; // public always allowed
    return n.audience == audience;
  }

  return state.items.where(allowed).toList();
});
