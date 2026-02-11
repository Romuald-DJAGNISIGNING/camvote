import 'package:flutter/foundation.dart';

import '../../centers/models/voting_center.dart';

/// Keep this minimal & backend-ready.
/// Later we’ll add: docScanResult, livenessResult, biometricConfirmation, etc.
@immutable
class RegistrationDraft {
  final String fullName;
  final DateTime? dateOfBirth;
  final String regionCode; // ex: "CE", "LT", "NW" etc.
  final String placeOfBirth;
  final String nationality;
  final String email;
  final VotingCenter? preferredCenter;
  final bool saved;

  const RegistrationDraft({
    required this.fullName,
    required this.dateOfBirth,
    required this.regionCode,
    required this.placeOfBirth,
    required this.nationality,
    required this.email,
    required this.preferredCenter,
    required this.saved,
  });

  const RegistrationDraft.empty()
    : fullName = '',
      dateOfBirth = null,
      regionCode = 'CE',
      placeOfBirth = '',
      nationality = '',
      email = '',
      preferredCenter = null,
      saved = false;

  RegistrationDraft copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? regionCode,
    String? placeOfBirth,
    String? nationality,
    String? email,
    VotingCenter? preferredCenter,
    bool? saved,
    bool clearDob = false,
    bool clearCenter = false,
  }) {
    return RegistrationDraft(
      fullName: fullName ?? this.fullName,
      dateOfBirth: clearDob ? null : (dateOfBirth ?? this.dateOfBirth),
      regionCode: regionCode ?? this.regionCode,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      nationality: nationality ?? this.nationality,
      email: email ?? this.email,
      preferredCenter: clearCenter
          ? null
          : (preferredCenter ?? this.preferredCenter),
      saved: saved ?? this.saved,
    );
  }

  bool get isValidBasicInfo =>
      fullName.trim().length >= 3 &&
      dateOfBirth != null &&
      regionCode.trim().isNotEmpty &&
      placeOfBirth.trim().isNotEmpty &&
      email.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'regionCode': regionCode,
    'placeOfBirth': placeOfBirth,
    'nationality': nationality,
    'email': email,
    'preferredCenter': preferredCenter?.toJson(),
    'saved': saved,
  };

  static RegistrationDraft fromJson(Map<String, dynamic> json) {
    final dob = json['dateOfBirth'];
    final centerRaw = json['preferredCenter'];
    return RegistrationDraft(
      fullName: (json['fullName'] as String?) ?? '',
      dateOfBirth: dob is String ? DateTime.tryParse(dob) : null,
      regionCode: (json['regionCode'] as String?) ?? 'CE',
      placeOfBirth: (json['placeOfBirth'] as String?) ?? '',
      nationality: (json['nationality'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      preferredCenter: centerRaw is Map<String, dynamic>
          ? VotingCenter.fromJson(centerRaw)
          : null,
      saved: (json['saved'] as bool?) ?? false,
    );
  }
}
