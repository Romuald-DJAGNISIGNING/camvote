import 'package:cloud_firestore/cloud_firestore.dart';

class VoterCountdownProfile {
  final String status;
  final String fullName;
  final bool verified;
  final DateTime? dateOfBirth;
  final DateTime? cardExpiry;
  final DateTime? suspensionEndsAt;
  final DateTime? eligibleAt;

  const VoterCountdownProfile({
    required this.status,
    required this.fullName,
    required this.verified,
    required this.dateOfBirth,
    required this.cardExpiry,
    required this.suspensionEndsAt,
    required this.eligibleAt,
  });

  bool get isSuspended => _normalizedStatus == 'suspended';
  bool get isPreEligible => _normalizedStatus == 'pre_eligible';
  String get _normalizedStatus => _normalizeStatus(status);

  static VoterCountdownProfile fromJson(Map<String, dynamic> data) {
    return VoterCountdownProfile(
      status: (data['status'] as String?) ?? '',
      fullName: (data['fullName'] as String?) ?? '',
      verified: (data['verified'] as bool?) ?? false,
      dateOfBirth: _parseDate(data['dob'] ?? data['dateOfBirth']),
      cardExpiry: _parseDate(data['cardExpiry'] ?? data['docExpiry']),
      suspensionEndsAt: _parseDate(
        data['suspensionEndsAt'] ?? data['suspendedUntil'],
      ),
      eligibleAt: _parseDate(data['eligibleAt'] ?? data['eligibilityAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  static String _normalizeStatus(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return '';
    if (normalized == 'preeligible') return 'pre_eligible';
    if (normalized == 'pre-eligible') return 'pre_eligible';
    if (normalized == 'registered_preeligible') return 'pre_eligible';
    if (normalized == 'registered_pre_eligible') return 'pre_eligible';
    return normalized;
  }
}
