import 'package:flutter/foundation.dart';

@immutable
class RegistrationEnrollment {
  final bool biometricEnrolled;
  final bool livenessVerified;
  final DateTime? completedAt;

  const RegistrationEnrollment({
    required this.biometricEnrolled,
    required this.livenessVerified,
    required this.completedAt,
  });

  const RegistrationEnrollment.empty()
    : biometricEnrolled = false,
      livenessVerified = false,
      completedAt = null;

  bool get isComplete => biometricEnrolled && livenessVerified;

  RegistrationEnrollment copyWith({
    bool? biometricEnrolled,
    bool? livenessVerified,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return RegistrationEnrollment(
      biometricEnrolled: biometricEnrolled ?? this.biometricEnrolled,
      livenessVerified: livenessVerified ?? this.livenessVerified,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'biometricEnrolled': biometricEnrolled,
    'livenessVerified': livenessVerified,
    'completedAt': completedAt?.toIso8601String(),
  };

  static RegistrationEnrollment fromJson(Map<String, dynamic> json) {
    final raw = json['completedAt'];
    return RegistrationEnrollment(
      biometricEnrolled: (json['biometricEnrolled'] as bool?) ?? false,
      livenessVerified: (json['livenessVerified'] as bool?) ?? false,
      completedAt: raw is String ? DateTime.tryParse(raw) : null,
    );
  }
}
