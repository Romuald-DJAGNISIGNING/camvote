import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../core/firebase/firebase_auth_scope.dart';
import '../../../core/network/worker_client.dart';
import '../../../core/offline/offline_sync_store.dart';
import '../../../core/theme/role_theme.dart';

import '../models/admin_support_ticket.dart';
import '../models/camguide_chat.dart';
import '../models/support_ticket.dart';

class SupportRepository {
  SupportRepository({WorkerClient? workerClient, FirebaseAuth? auth})
    : _workerClient = workerClient ?? WorkerClient(),
      _auth = auth ?? FirebaseAuth.instance;

  final WorkerClient _workerClient;
  final FirebaseAuth _auth;

  Future<SupportTicketResult> submitTicket(SupportTicket ticket) async {
    final payload = <String, dynamic>{
      'name': ticket.name,
      'email': ticket.email,
      'registrationId': ticket.registrationId,
      'category': ticket.category.apiValue,
      'message': ticket.message,
    };
    Map<String, dynamic> response;
    try {
      response = await _workerClient.post(
        '/v1/support/ticket',
        data: payload,
        authRequired: _hasSignedInUser,
        allowOfflineQueue: true,
        queueType: 'support_ticket',
      );
    } on WorkerException catch (error) {
      // Backward compatibility for deployments still exposing plural route only.
      if (error.statusCode != 404 && error.statusCode != 405) {
        rethrow;
      }
      response = await _workerClient.post(
        '/v1/support/tickets',
        data: payload,
        authRequired: _hasSignedInUser,
        allowOfflineQueue: true,
        queueType: 'support_ticket',
      );
    }
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

  Future<CamGuideReply> askCamGuide({
    required String question,
    required Locale locale,
    required AppRole role,
    String lastIntentId = '',
  }) async {
    final response = await _workerClient.post(
      '/v1/camguide/chat',
      data: {
        'question': question.trim(),
        'locale': locale.languageCode.trim().toLowerCase(),
        'role': role.apiValue,
        if (lastIntentId.trim().isNotEmpty) 'lastIntentId': lastIntentId.trim(),
      },
      authRequired: false,
    );

    final answer = _asString(response['answer']);
    if (answer.isEmpty) {
      throw StateError('CamGuide returned an empty answer.');
    }

    return CamGuideReply(
      answer: answer,
      followUps: _asStringList(response['followUps']),
      sourceHints: _asStringList(response['sourceHints']),
      confidence: _asDouble(response['confidence']).clamp(0, 1),
      intentId: _asString(response['intentId']),
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

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  List<String> _asStringList(dynamic value) {
    if (value is! List) return const <String>[];
    final out = <String>[];
    for (final item in value) {
      final text = _asString(item);
      if (text.isNotEmpty) {
        out.add(text);
      }
    }
    return out;
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(_asString(value)) ?? 0;
  }
}
