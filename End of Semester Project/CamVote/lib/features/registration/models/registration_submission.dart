class RegistrationSubmission {
  final String fullName;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String nationality;
  final String regionCode;
  final String documentType;
  final String? documentNumber;
  final DateTime? docExpiry;
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
    required this.documentNumber,
    required this.docExpiry,
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
    'fullName': fullName,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'place_of_birth': placeOfBirth,
    'placeOfBirth': placeOfBirth,
    'nationality': nationality,
    'region_code': regionCode,
    'regionCode': regionCode,
    'document_type': documentType,
    'documentType': documentType,
    'document_number': documentNumber,
    'documentNumber': documentNumber,
    'documentIdNumber': documentNumber,
    'doc_expiry': docExpiry?.toIso8601String(),
    'docExpiry': docExpiry?.toIso8601String(),
    'cardExpiry': docExpiry?.toIso8601String(),
    'ocr_raw_text': ocrRawText,
    'ocrRawText': ocrRawText,
    'ocr_summary': ocrSummary,
    'ocrSummary': ocrSummary,
    'ocr_name_ok': ocrNameOk,
    'ocrNameOk': ocrNameOk,
    'ocr_dob_ok': ocrDobOk,
    'ocrDobOk': ocrDobOk,
    'ocr_pob_ok': ocrPobOk,
    'ocrPobOk': ocrPobOk,
    'ocr_nationality_ok': ocrNationalityOk,
    'ocrNationalityOk': ocrNationalityOk,
    'biometric_enrolled': biometricEnrolled,
    'biometricEnrolled': biometricEnrolled,
    'liveness_verified': livenessVerified,
    'livenessVerified': livenessVerified,
    'enrollment_completed_at': enrollmentCompletedAt?.toIso8601String(),
    'enrollmentCompletedAt': enrollmentCompletedAt?.toIso8601String(),
    'preferred_center_id': preferredCenterId,
    'preferredCenterId': preferredCenterId,
    'centerId': preferredCenterId,
  };
}
