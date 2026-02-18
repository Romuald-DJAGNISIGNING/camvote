import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/worker_client.dart';
import '../../../core/firebase/firebase_auth_scope.dart';
import '../../../core/offline/offline_sync_store.dart';
import '../models/tip_models.dart';
import '../utils/tip_checkout_links.dart';

class TipRepository {
  TipRepository({WorkerClient? workerClient, FirebaseAuth? auth})
    : _workerClient = workerClient ?? WorkerClient(),
      _auth = auth ?? FirebaseAuth.instance;

  final WorkerClient _workerClient;
  final FirebaseAuth _auth;

  Future<TipCheckoutSession> createTapTapSendIntent({
    required String senderName,
    required String senderEmail,
    required int amount,
    required String currency,
    bool anonymous = false,
    String message = '',
    String source = 'camvote_app',
  }) async {
    final response = await _workerClient.post(
      '/v1/payments/tips/taptap-send-intent',
      authRequired: _hasSignedInUser,
      data: {
        'senderName': senderName.trim(),
        'senderEmail': senderEmail.trim(),
        'amount': amount,
        'currency': currency.trim().toUpperCase(),
        'anonymous': anonymous,
        'message': message.trim(),
        'source': source,
      },
    );
    return _parseSession(response);
  }

  Future<TipCheckoutSession> createMaxItQrIntent({
    required String senderName,
    required String senderEmail,
    required int amount,
    required String currency,
    bool anonymous = false,
    String message = '',
    String source = 'camvote_app',
  }) async {
    final response = await _workerClient.post(
      '/v1/payments/tips/maxit-qr-intent',
      authRequired: _hasSignedInUser,
      data: {
        'senderName': senderName.trim(),
        'senderEmail': senderEmail.trim(),
        'amount': amount,
        'currency': currency.trim().toUpperCase(),
        'anonymous': anonymous,
        'message': message.trim(),
        'source': source,
      },
    );
    return _parseSession(response);
  }

  Future<TipCheckoutSession> createRemitlyIntent({
    required String senderName,
    required String senderEmail,
    required int amount,
    required String currency,
    bool anonymous = false,
    String message = '',
    String source = 'camvote_app',
  }) async {
    final payload = {
      'senderName': senderName.trim(),
      'senderEmail': senderEmail.trim(),
      'amount': amount,
      'currency': currency.trim().toUpperCase(),
      'anonymous': anonymous,
      'message': message.trim(),
      'source': source,
    };

    try {
      final response = await _workerClient.post(
        '/v1/payments/tips/remitly-intent',
        authRequired: _hasSignedInUser,
        data: payload,
      );
      return _parseSession(response);
    } on WorkerException catch (error) {
      // Backward compatibility when deployed worker is not yet upgraded.
      if (error.statusCode != 404) rethrow;
      return _createLegacyRemitlySession(payload);
    }
  }

  Future<TipStatusResult> fetchStatus(String tipId) async {
    final response = await _workerClient.get(
      '/v1/payments/tips/${Uri.encodeComponent(tipId)}/status',
      authRequired: false,
    );
    final receiptUrlsRaw = response['receiptUrls'];
    final receiptUrls = receiptUrlsRaw is List
        ? receiptUrlsRaw.map((e) => e.toString()).toList()
        : const <String>[];
    return TipStatusResult(
      tipId: response['tipId']?.toString() ?? tipId,
      status: response['status']?.toString() ?? 'pending',
      provider: response['provider']?.toString() ?? 'taptap_send',
      amount: _safeInt(response['amount']),
      currency: response['currency']?.toString() ?? 'XAF',
      senderName: response['senderName']?.toString() ?? 'Supporter',
      anonymous: _safeBool(response['anonymous']),
      senderEmail: response['senderEmail']?.toString(),
      thankYouMessage: response['thankYouMessage']?.toString(),
      receiptUrls: receiptUrls,
    );
  }

  Future<TipProofSubmissionResult> submitTapTapSendProof({
    required String tipId,
    required String reference,
    String note = '',
    List<String> attachments = const [],
  }) async {
    final response = await _workerClient.post(
      '/v1/payments/tips/taptap-send/submit',
      authRequired: _hasSignedInUser,
      data: {
        'tipId': tipId.trim(),
        'reference': reference.trim(),
        'note': note.trim(),
        'attachments': attachments,
      },
      allowOfflineQueue: true,
      queueType: 'tip_proof_submit',
    );
    final queued = response['queued'] == true;
    final queueId = response['offlineQueueId']?.toString() ?? '';
    return TipProofSubmissionResult(
      tipId: response['tipId']?.toString() ?? tipId.trim(),
      status:
          response['status']?.toString() ??
          (queued ? 'queued_offline' : 'submitted'),
      queuedOffline: queued,
      offlineQueueId: queueId,
      message: response['message']?.toString() ?? '',
    );
  }

  Future<String> uploadReceipt(XFile file) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('auth_required');
    }
    final name = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final bytes = await file.readAsBytes();
    final contentType = file.mimeType ?? 'application/octet-stream';
    final result = await _workerClient.post(
      '/v1/storage/upload',
      data: {
        'path': 'tip_receipts/${user.uid}/$name',
        'contentBase64': base64Encode(bytes),
        'contentType': contentType,
      },
    );
    final url = result['downloadUrl'] as String? ?? '';
    if (url.isEmpty) {
      throw StateError('upload_failed');
    }
    return url;
  }

  Future<void> notifyTip(
    String tipId, {
    bool inApp = true,
    bool email = true,
  }) async {
    await _workerClient.post(
      '/v1/payments/tips/${Uri.encodeComponent(tipId)}/notify',
      authRequired: false,
      data: {'inApp': inApp, 'email': email},
      allowOfflineQueue: true,
      queueType: 'tip_notify',
    );
  }

  Future<int> pendingOfflineTipQueueCount() async {
    final proof = await OfflineSyncStore.pendingCount(
      queueType: 'tip_proof_submit',
    );
    final notify = await OfflineSyncStore.pendingCount(queueType: 'tip_notify');
    return proof + notify;
  }

  TipCheckoutSession _parseSession(Map<String, dynamic> response) {
    final orangeMoney = response['orangeMoney'] is Map
        ? (response['orangeMoney'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final currencyRaw = response['currency']?.toString().trim().toUpperCase();
    return TipCheckoutSession(
      tipId: response['tipId']?.toString() ?? '',
      status: response['status']?.toString() ?? 'pending',
      provider: response['provider']?.toString() ?? '',
      anonymous: _safeBool(response['anonymous']),
      amount: _safeInt(response['amount']),
      currency: (currencyRaw == null || currencyRaw.isEmpty)
          ? 'XAF'
          : currencyRaw,
      checkoutUrl: response['checkoutUrl']?.toString(),
      qrUrl: response['qrUrl']?.toString(),
      deepLink: response['deepLink']?.toString(),
      orangeMoneyNumber: orangeMoney['number']?.toString(),
      orangeMoneyMaskedNumber: orangeMoney['maskedNumber']?.toString(),
      orangeMoneyOwner: orangeMoney['ownerName']?.toString(),
    );
  }

  Future<TipCheckoutSession> _createLegacyRemitlySession(
    Map<String, dynamic> payload,
  ) async {
    final response = await _workerClient.post(
      '/v1/payments/tips/create-session',
      authRequired: _hasSignedInUser,
      data: payload,
    );
    final legacy = _parseSession(response);
    final recipientName = legacy.orangeMoneyOwner?.trim().isNotEmpty == true
        ? legacy.orangeMoneyOwner!.trim()
        : AppConfig.tipOrangeMoneyName.trim();
    final recipientNumber = legacy.orangeMoneyNumber?.trim().isNotEmpty == true
        ? legacy.orangeMoneyNumber!.trim()
        : AppConfig.tipOrangeMoneyNumber.trim();
    final currency = legacy.currency.trim().isNotEmpty
        ? legacy.currency.trim().toUpperCase()
        : 'XAF';
    final amount = legacy.amount;
    final fallbackLinks = buildFallbackTipCheckoutLinks(
      provider: TipCheckoutProvider.remitly,
      tipId: legacy.tipId,
      amount: amount,
      currency: currency,
      recipientName: recipientName,
      recipientNumber: recipientNumber,
    );

    return legacy.copyWith(
      provider: 'remitly',
      checkoutUrl: fallbackLinks.checkoutUrl,
      deepLink: fallbackLinks.deepLink,
    );
  }

  int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _safeBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'on';
  }

  bool get _hasSignedInUser {
    try {
      if (kIsWeb) {
        final app = resolveFirebaseAppForScope();
        return FirebaseAuth.instanceFor(app: app).currentUser != null;
      }
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }
}
