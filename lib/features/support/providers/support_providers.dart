import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/support_repository.dart';
import '../models/support_ticket.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportRepository(dio);
});

final supportTicketProvider =
    AsyncNotifierProvider<SupportTicketController, SupportTicketResult?>(
  SupportTicketController.new,
);

class SupportTicketController extends AsyncNotifier<SupportTicketResult?> {
  @override
  Future<SupportTicketResult?> build() async => null;

  Future<SupportTicketResult?> submit(SupportTicket ticket) async {
    if (!AppConfig.hasApiBaseUrl) {
      state = AsyncData(
        const SupportTicketResult(
          ticketId: '',
          status: 'error',
          message: 'API base URL is not configured.',
        ),
      );
      return state.value;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(supportRepositoryProvider);
      return repo.submitTicket(ticket);
    });

    return state.value;
  }
}
