import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_support_ticket.dart';
import '../data/camguide_assistant.dart';
import '../data/support_repository.dart';
import '../models/support_ticket.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});

final camGuideAssistantProvider = Provider<CamGuideAssistant>((ref) {
  return CamGuideAssistant();
});

final pendingOfflineSupportTicketsProvider = StreamProvider<int>((ref) async* {
  final repo = ref.watch(supportRepositoryProvider);
  yield await repo.pendingOfflineTicketCount();
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 6));
    yield await repo.pendingOfflineTicketCount();
  }
});

final supportTicketProvider =
    AsyncNotifierProvider<SupportTicketController, SupportTicketResult?>(
      SupportTicketController.new,
    );

class SupportTicketController extends AsyncNotifier<SupportTicketResult?> {
  @override
  Future<SupportTicketResult?> build() async => null;

  Future<SupportTicketResult?> submit(SupportTicket ticket) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(supportRepositoryProvider);
      return repo.submitTicket(ticket);
    });
    ref.invalidate(pendingOfflineSupportTicketsProvider);
    return state.value;
  }
}

class AdminSupportQuery {
  final String query;
  final AdminSupportTicketStatus? status;

  const AdminSupportQuery({this.query = '', this.status});

  AdminSupportQuery copyWith({
    String? query,
    AdminSupportTicketStatus? status,
    bool clearStatus = false,
  }) {
    return AdminSupportQuery(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

final adminSupportQueryProvider =
    NotifierProvider<AdminSupportQueryController, AdminSupportQuery>(
      AdminSupportQueryController.new,
    );

class AdminSupportQueryController extends Notifier<AdminSupportQuery> {
  @override
  AdminSupportQuery build() => const AdminSupportQuery();

  void update(AdminSupportQuery query) => state = query;
}

final adminSupportTicketsProvider = FutureProvider<List<AdminSupportTicket>>((
  ref,
) async {
  final repo = ref.read(supportRepositoryProvider);
  final q = ref.watch(adminSupportQueryProvider);
  return repo.fetchAdminTickets(query: q.query, status: q.status);
});

final adminSupportControllerProvider = Provider<AdminSupportController>((ref) {
  return AdminSupportController(ref);
});

class AdminSupportController {
  final Ref _ref;

  AdminSupportController(this._ref);

  Future<AdminSupportRespondResult> respond({
    required String ticketId,
    required String responseMessage,
    AdminSupportTicketStatus status = AdminSupportTicketStatus.answered,
  }) async {
    final repo = _ref.read(supportRepositoryProvider);
    final result = await repo.respondToTicket(
      ticketId: ticketId,
      responseMessage: responseMessage,
      status: status,
    );
    _ref.invalidate(adminSupportTicketsProvider);
    return result;
  }
}
