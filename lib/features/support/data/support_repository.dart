import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firebase/firebase_auth_scope.dart';
import '../../../core/network/worker_client.dart';
import '../../../core/offline/offline_sync_store.dart';

import '../models/admin_support_ticket.dart';
import '../models/support_ticket.dart';

class SupportRepository {
  SupportRepository({WorkerClient? workerClient, FirebaseAuth? auth})
    : _workerClient = workerClient ?? WorkerClient(),
      _auth = auth ?? FirebaseAuth.instance;

  final WorkerClient _workerClient;
  final FirebaseAuth _auth;

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
      authRequired: _hasSignedInUser,
      allowOfflineQueue: true,
      queueType: 'support_ticket',
    );
    final queued = response['queued'] == true;
    final queueId = response['offlineQueueId']?.toString() ?? '';
    return SupportTicketResult(
      ticketId: response['ticketId']?.toString() ?? '',
      status:
          response['status']?.toString() ??
          (queued ? 'queued_offline' : 'received'),
      message: response['message']?.toString() ?? '',
      queuedOffline: queued,
      offlineQueueId: queueId,
    );
  }

  bool get _hasSignedInUser {
    try {
      if (kIsWeb) {
        final app = resolveFirebaseAppForScope();
        return FirebaseAuth.instanceFor(app: app).currentUser != null;
      }
      return _auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  Future<int> pendingOfflineTicketCount() {
    return OfflineSyncStore.pendingCount(queueType: 'support_ticket');
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
      allowOfflineQueue: true,
      queueType: 'support_ticket_response',
    );
    final queued = response['queued'] == true;
    final queueId = response['offlineQueueId']?.toString() ?? '';

    return AdminSupportRespondResult(
      ticketId: (response['ticketId']?.toString() ?? normalizedTicketId).trim(),
      status: queued
          ? status
          : adminSupportTicketStatusFromApi(response['status']?.toString()),
      queuedOffline: queued,
      offlineQueueId: queueId,
    );
  }
}
