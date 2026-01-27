import 'package:flutter/foundation.dart';

import '../services/ocr/ocr_models.dart';
import 'registration_identity.dart';

@immutable
class RegistrationReviewPayload {
  final RegistrationIdentity identity;
  final OfficialDocumentType docType;
  final OcrExtractedIdentity? extracted;
  final OcrValidationResult? validation;

  const RegistrationReviewPayload({
    required this.identity,
    required this.docType,
    required this.extracted,
    required this.validation,
  });

  bool get isVerified => validation?.ok ?? false;
}
