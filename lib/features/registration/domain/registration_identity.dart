import 'package:flutter/foundation.dart';

@immutable
class RegistrationIdentity {
  final String fullName; // user-entered
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String nationality;

  const RegistrationIdentity({
    required this.fullName,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.nationality,
  });

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'placeOfBirth': placeOfBirth,
    'nationality': nationality,
  };

  factory RegistrationIdentity.fromMap(Map<String, dynamic> map) {
    return RegistrationIdentity(
      fullName: (map['fullName'] as String?) ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      placeOfBirth: (map['placeOfBirth'] as String?) ?? '',
      nationality: (map['nationality'] as String?) ?? '',
    );
  }
}
