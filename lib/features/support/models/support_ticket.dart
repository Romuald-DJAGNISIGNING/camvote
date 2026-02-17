import 'package:flutter/foundation.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

enum SupportCategory {
  registration,
  voting,
  biometrics,
  fraud,
  technical,
  other,
}

extension SupportCategoryX on SupportCategory {
  String labelFor(AppLocalizations t) => switch (this) {
    SupportCategory.registration => t.supportCategoryRegistration,
    SupportCategory.voting => t.supportCategoryVoting,
    SupportCategory.biometrics => t.supportCategoryBiometrics,
    SupportCategory.fraud => t.supportCategoryFraud,
    SupportCategory.technical => t.supportCategoryTechnical,
    SupportCategory.other => t.supportCategoryOther,
  };

  String get apiValue => switch (this) {
    SupportCategory.registration => 'registration',
    SupportCategory.voting => 'voting',
    SupportCategory.biometrics => 'biometrics',
    SupportCategory.fraud => 'fraud',
    SupportCategory.technical => 'technical',
    SupportCategory.other => 'other',
  };
}

@immutable
class SupportTicket {
  final String name;
  final String email;
  final String registrationId;
  final SupportCategory category;
  final String message;

  const SupportTicket({
    required this.name,
    required this.email,
    required this.registrationId,
    required this.category,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'registration_id': registrationId,
    'category': category.apiValue,
    'message': message,
  };
}

class SupportTicketResult {
  final String ticketId;
  final String status;
  final String message;
  final bool queuedOffline;
  final String offlineQueueId;

  const SupportTicketResult({
    required this.ticketId,
    required this.status,
    required this.message,
    this.queuedOffline = false,
    this.offlineQueueId = '',
  });

  factory SupportTicketResult.fromJson(Map<String, dynamic> json) {
    return SupportTicketResult(
      ticketId: (json['ticket_id'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'received',
      message: (json['message'] as String?) ?? '',
      queuedOffline: json['queued'] == true,
      offlineQueueId: (json['offlineQueueId'] as String?) ?? '',
    );
  }
}
