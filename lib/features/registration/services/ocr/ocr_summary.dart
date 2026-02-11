import '../../../../gen/l10n/app_localizations.dart';
import 'ocr_models.dart';

String buildOcrSummary(
  AppLocalizations t, {
  required OcrValidationResult validation,
  required OcrExtractedIdentity? extracted,
}) {
  final pendingNationality = _isNationalityPending(extracted);
  if (validation.ok) {
    return pendingNationality
        ? t.ocrSummaryVerifiedPendingNationality
        : t.ocrSummaryVerified;
  }

  final issues = <String>[];
  if (!validation.nameOk) issues.add(t.ocrIssueNameMismatch);
  if (!validation.dobOk) issues.add(t.ocrIssueDobMismatch);
  if (!validation.pobOk) issues.add(t.ocrIssuePobMismatch);
  if (!validation.nationalityOk) issues.add(t.ocrIssueForeignDocument);
  if (pendingNationality) issues.add(t.ocrSummaryNationalityPending);
  return issues.isEmpty ? t.ocrRejectedTitle : issues.join(' • ');
}

bool isForeignDocument(OcrValidationResult validation) =>
    validation.nationalityOk == false;

bool _isNationalityPending(OcrExtractedIdentity? extracted) {
  return (extracted?.nationality ?? '').trim().isEmpty;
}
