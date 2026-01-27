import 'package:flutter/foundation.dart';

enum OfficialDocumentType { nationalId, passport, other }

enum OcrStatus { idle, picking, processing, done, failed }

@immutable
class OcrExtractedIdentity {
  final String rawText;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? nationality;

  const OcrExtractedIdentity({
    required this.rawText,
    this.fullName,
    this.dateOfBirth,
    this.placeOfBirth,
    this.nationality,
  });
}

@immutable
class OcrValidationResult {
  final bool ok;
  final String summary;
  final bool nameOk;
  final bool dobOk;
  final bool pobOk;
  final bool nationalityOk;

  const OcrValidationResult({
    required this.ok,
    required this.summary,
    required this.nameOk,
    required this.dobOk,
    required this.pobOk,
    required this.nationalityOk,
  });

  static OcrValidationResult failed(String summary) => OcrValidationResult(
        ok: false,
        summary: summary,
        nameOk: false,
        dobOk: false,
        pobOk: false,
        nationalityOk: false,
      );
}