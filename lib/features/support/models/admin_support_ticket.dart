import 'package:flutter/foundation.dart';

enum AdminSupportTicketStatus { open, answered, resolved, closed, unknown }

AdminSupportTicketStatus adminSupportTicketStatusFromApi(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'open':
      return AdminSupportTicketStatus.open;
    case 'answered':
      return AdminSupportTicketStatus.answered;
    case 'resolved':
      return AdminSupportTicketStatus.resolved;
    case 'closed':
      return AdminSupportTicketStatus.closed;
    default:
      return AdminSupportTicketStatus.unknown;
  }
}

extension AdminSupportTicketStatusX on AdminSupportTicketStatus {
  String get apiValue => switch (this) {
    AdminSupportTicketStatus.open => 'open',
    AdminSupportTicketStatus.answered => 'answered',
    AdminSupportTicketStatus.resolved => 'resolved',
    AdminSupportTicketStatus.closed => 'closed',
    AdminSupportTicketStatus.unknown => 'unknown',
  };

  String get label => switch (this) {
    AdminSupportTicketStatus.open => 'Open',
    AdminSupportTicketStatus.answered => 'Answered',
    AdminSupportTicketStatus.resolved => 'Resolved',
    AdminSupportTicketStatus.closed => 'Closed',
    AdminSupportTicketStatus.unknown => 'Unknown',
  };
}

@immutable
class AdminSupportTicket {
  final String id;
  final String userId;
  final String role;
  final String name;
  final String email;
  final String registrationId;
  final String category;
  final String message;
  final AdminSupportTicketStatus status;
  final String responseMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? respondedAt;
  final String respondedBy;

  const AdminSupportTicket({
    required this.id,
    required this.userId,
    required this.role,
    required this.name,
    required this.email,
    required this.registrationId,
    required this.category,
    required this.message,
    required this.status,
    required this.responseMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.respondedAt,
    required this.respondedBy,
  });

  factory AdminSupportTicket.fromApi(Map<String, dynamic> json) {
    final embeddedData = json['data'];
    final data = embeddedData is Map
        ? embeddedData.cast<String, dynamic>()
        : json;
    final id = (json['id']?.toString() ?? data['id']?.toString() ?? '').trim();

    DateTime parseDate(String key) {
      final raw = (data[key]?.toString() ?? '').trim();
      if (raw.isEmpty) return DateTime.now();
      return DateTime.tryParse(raw) ?? DateTime.now();
    }

    DateTime? parseDateNullable(String key) {
      final raw = (data[key]?.toString() ?? '').trim();
      if (raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return AdminSupportTicket(
      id: id,
      userId: (data['userId']?.toString() ?? '').trim(),
      role: (data['role']?.toString() ?? '').trim(),
      name: (data['name']?.toString() ?? '').trim(),
      email: (data['email']?.toString() ?? '').trim(),
      registrationId: (data['registrationId']?.toString() ?? '').trim(),
      category: (data['category']?.toString() ?? '').trim(),
      message: (data['message']?.toString() ?? '').trim(),
      status: adminSupportTicketStatusFromApi(data['status']?.toString()),
      responseMessage: (data['responseMessage']?.toString() ?? '').trim(),
      createdAt: parseDate('createdAt'),
      updatedAt: parseDate('updatedAt'),
      respondedAt: parseDateNullable('respondedAt'),
      respondedBy: (data['respondedBy']?.toString() ?? '').trim(),
    );
  }
}

@immutable
class AdminSupportRespondResult {
  final String ticketId;
  final AdminSupportTicketStatus status;

  const AdminSupportRespondResult({
    required this.ticketId,
    required this.status,
  });
}
