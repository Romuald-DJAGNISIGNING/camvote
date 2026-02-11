import '../../../core/network/worker_client.dart';

import '../models/admin_support_ticket.dart';
import '../models/support_ticket.dart';

class SupportRepository {
  SupportRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Future<SupportTicketResult> submitTicket(SupportTicket ticket) async {
    final response = await _workerClient.post(
      '/v1/support/ticket',
      data: {
        'name': ticket.name,
        'email': ticket.email,
        'registrationId': ticket.registrationId,
        'category': ticket.category.apiValue,
        'message': ticket.message,
      },
    );
    return SupportTicketResult(
      ticketId: response['ticketId']?.toString() ?? '',
      status: response['status']?.toString() ?? 'received',
      message: response['message']?.toString() ?? '',
    );
  }

  Future<List<AdminSupportTicket>> fetchAdminTickets({
    String query = '',
    AdminSupportTicketStatus? status,
  }) async {
    final normalizedQuery = query.trim();
    final normalizedStatus = status;
    final params = <String, dynamic>{};
    if (normalizedQuery.isNotEmpty) {
      params['query'] = normalizedQuery;
    }
    if (normalizedStatus != null &&
        normalizedStatus != AdminSupportTicketStatus.unknown) {
      params['status'] = normalizedStatus.apiValue;
    }

    final response = await _workerClient.get(
      '/v1/admin/support/tickets',
      queryParameters: params.isEmpty ? null : params,
    );
    final raw = response['tickets'];
    if (raw is! List) return const <AdminSupportTicket>[];

    return raw
        .whereType<Map>()
        .map((item) => AdminSupportTicket.fromApi(item.cast<String, dynamic>()))
        .toList();
  }

  Future<AdminSupportRespondResult> respondToTicket({
    required String ticketId,
    required String responseMessage,
    AdminSupportTicketStatus status = AdminSupportTicketStatus.answered,
  }) async {
    final normalizedTicketId = ticketId.trim();
    final normalizedMessage = responseMessage.trim();
    if (normalizedTicketId.isEmpty) {
      throw StateError('ticketId is required');
    }
    if (normalizedMessage.isEmpty) {
      throw StateError('responseMessage is required');
    }

    final response = await _workerClient.post(
      '/v1/admin/support/tickets/respond',
      data: {
        'ticketId': normalizedTicketId,
        'responseMessage': normalizedMessage,
        'status': status.apiValue,
      },
    );

    return AdminSupportRespondResult(
      ticketId: (response['ticketId']?.toString() ?? normalizedTicketId).trim(),
      status: adminSupportTicketStatusFromApi(response['status']?.toString()),
    );
  }
}
