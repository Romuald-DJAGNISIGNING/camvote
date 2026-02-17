import 'package:flutter/foundation.dart';

@immutable
class AdminTipRecord {
  final String id;
  final String provider;
  final String status;
  final int amount;
  final String currency;
  final String senderName;
  final String senderEmail;
  final bool anonymous;
  final String reference;
  final String note;
  final List<String> receiptUrls;
  final DateTime createdAt;

  const AdminTipRecord({
    required this.id,
    required this.provider,
    required this.status,
    required this.amount,
    required this.currency,
    required this.senderName,
    required this.senderEmail,
    required this.anonymous,
    required this.reference,
    required this.note,
    required this.receiptUrls,
    required this.createdAt,
  });

  factory AdminTipRecord.fromApi(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;
    final id = (json['id']?.toString() ?? data['id']?.toString() ?? '').trim();
    final createdAtRaw = (data['createdAt']?.toString() ?? '').trim();
    final receiptRaw = data['receiptUrls'];
    final receiptUrls = receiptRaw is List
        ? receiptRaw.map((e) => e.toString()).toList()
        : const <String>[];

    return AdminTipRecord(
      id: id,
      provider: (data['provider']?.toString() ?? '').trim(),
      status: (data['status']?.toString() ?? '').trim(),
      amount: _safeInt(data['amount']),
      currency: (data['currency']?.toString() ?? 'XAF').trim(),
      senderName: (data['senderName']?.toString() ?? '').trim(),
      senderEmail: (data['senderEmail']?.toString() ?? '').trim(),
      anonymous: data['anonymous'] == true,
      reference: (data['providerReference']?.toString() ?? '').trim(),
      note: (data['submitNote']?.toString() ?? '').trim(),
      receiptUrls: receiptUrls,
      createdAt: createdAtRaw.isEmpty
          ? DateTime.now()
          : DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
    );
  }
}

@immutable
class AdminTipDecisionResult {
  final bool queuedOffline;
  final String offlineQueueId;

  const AdminTipDecisionResult({
    this.queuedOffline = false,
    this.offlineQueueId = '',
  });
}

int _safeInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
