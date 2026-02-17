import 'package:flutter/foundation.dart';

enum TipProviderChannel { tapTapSend, remitly, maxItQr }

extension TipProviderChannelX on TipProviderChannel {
  String get apiValue => switch (this) {
    TipProviderChannel.tapTapSend => 'taptap_send',
    TipProviderChannel.remitly => 'remitly',
    TipProviderChannel.maxItQr => 'maxit_qr',
  };
}

@immutable
class TipCheckoutSession {
  const TipCheckoutSession({
    required this.tipId,
    required this.status,
    required this.provider,
    this.anonymous = false,
    this.amount = 0,
    this.currency = 'XAF',
    this.checkoutUrl,
    this.qrUrl,
    this.deepLink,
    this.orangeMoneyNumber,
    this.orangeMoneyMaskedNumber,
    this.orangeMoneyOwner,
  });

  final String tipId;
  final String status;
  final String provider;
  final bool anonymous;
  final int amount;
  final String currency;
  final String? checkoutUrl;
  final String? qrUrl;
  final String? deepLink;
  final String? orangeMoneyNumber;
  final String? orangeMoneyMaskedNumber;
  final String? orangeMoneyOwner;

  TipCheckoutSession copyWith({
    String? tipId,
    String? status,
    String? provider,
    bool? anonymous,
    int? amount,
    String? currency,
    String? checkoutUrl,
    String? qrUrl,
    String? deepLink,
    String? orangeMoneyNumber,
    String? orangeMoneyMaskedNumber,
    String? orangeMoneyOwner,
  }) {
    return TipCheckoutSession(
      tipId: tipId ?? this.tipId,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      anonymous: anonymous ?? this.anonymous,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      qrUrl: qrUrl ?? this.qrUrl,
      deepLink: deepLink ?? this.deepLink,
      orangeMoneyNumber: orangeMoneyNumber ?? this.orangeMoneyNumber,
      orangeMoneyMaskedNumber:
          orangeMoneyMaskedNumber ?? this.orangeMoneyMaskedNumber,
      orangeMoneyOwner: orangeMoneyOwner ?? this.orangeMoneyOwner,
    );
  }
}

@immutable
class TipStatusResult {
  const TipStatusResult({
    required this.tipId,
    required this.status,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.senderName,
    this.anonymous = false,
    this.senderEmail,
    this.thankYouMessage,
    this.receiptUrls = const [],
  });

  final String tipId;
  final String status;
  final String provider;
  final int amount;
  final String currency;
  final String senderName;
  final bool anonymous;
  final String? senderEmail;
  final String? thankYouMessage;
  final List<String> receiptUrls;

  bool get isSuccess {
    final normalized = status.toLowerCase();
    return normalized == 'success' ||
        normalized == 'accepted' ||
        normalized == 'delivered' ||
        normalized == 'completed';
  }
}

@immutable
class TipProofSubmissionResult {
  const TipProofSubmissionResult({
    required this.tipId,
    required this.status,
    this.queuedOffline = false,
    this.offlineQueueId = '',
    this.message = '',
  });

  final String tipId;
  final String status;
  final bool queuedOffline;
  final String offlineQueueId;
  final String message;
}
