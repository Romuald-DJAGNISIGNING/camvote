class RegistrationSubmission {
  final String fullName;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String nationality;
  final String regionCode;
  final String documentType;
  final String? ocrRawText;
  final String? ocrSummary;
  final bool ocrNameOk;
  final bool ocrDobOk;
  final bool ocrPobOk;
  final bool ocrNationalityOk;
  final bool biometricEnrolled;
  final bool livenessVerified;
  final DateTime? enrollmentCompletedAt;
  final String? preferredCenterId;

  const RegistrationSubmission({
    required this.fullName,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.nationality,
    required this.regionCode,
    required this.documentType,
    required this.ocrRawText,
    required this.ocrSummary,
    required this.ocrNameOk,
    required this.ocrDobOk,
    required this.ocrPobOk,
    required this.ocrNationalityOk,
    required this.biometricEnrolled,
    required this.livenessVerified,
    required this.enrollmentCompletedAt,
    required this.preferredCenterId,
  });

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'place_of_birth': placeOfBirth,
    'nationality': nationality,
    'region_code': regionCode,
    'document_type': documentType,
    'ocr_raw_text': ocrRawText,
    'ocr_summary': ocrSummary,
    'ocr_name_ok': ocrNameOk,
    'ocr_dob_ok': ocrDobOk,
    'ocr_pob_ok': ocrPobOk,
    'ocr_nationality_ok': ocrNationalityOk,
    'biometric_enrolled': biometricEnrolled,
    'liveness_verified': livenessVerified,
    'enrollment_completed_at': enrollmentCompletedAt?.toIso8601String(),
    'preferred_center_id': preferredCenterId,
  };
}
