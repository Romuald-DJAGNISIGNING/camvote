import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../domain/registration_review_payload.dart';
import '../models/registration_submission.dart';
import '../models/registration_submission_result.dart';
import '../providers/registration_providers.dart';
import '../providers/registration_submission_controller.dart';
import '../services/ocr/ocr_models.dart';

class VoterRegistrationReviewScreen extends ConsumerStatefulWidget {
  final RegistrationReviewPayload payload;

  const VoterRegistrationReviewScreen({super.key, required this.payload});

  @override
  ConsumerState<VoterRegistrationReviewScreen> createState() =>
      _VoterRegistrationReviewScreenState();
}

class _VoterRegistrationReviewScreenState
    extends ConsumerState<VoterRegistrationReviewScreen> {
  bool _consent = false;
  bool _renewing = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final draft = ref.watch(voterRegistrationDraftProvider);
    final enrollment = ref.watch(registrationEnrollmentProvider);
    final submission = ref.watch(registrationSubmissionProvider);

    final validation = widget.payload.validation;
    final extracted = widget.payload.extracted;

    final canSubmit = _consent &&
        enrollment.isComplete &&
        widget.payload.isVerified &&
        draft.isValidBasicInfo;

    final docLabel = _docLabel(t, widget.payload.docType);
    final dobLabel = _formatDate(context, draft.dateOfBirth);
    final regionLabel = _regionLabel(t, draft.regionCode);
    final centerLabel = draft.preferredCenter?.name ?? t.votingCenterNotSelectedTitle;

    return Scaffold(
      appBar: AppBar(title: Text(t.registrationReviewTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.registrationReviewTitle,
                subtitle: t.registrationReviewSubtitle,
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: t.registrationSectionPersonalDetails,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: t.fullName, value: draft.fullName),
                    _Row(
                      label: t.dateOfBirth,
                      value: dobLabel.isEmpty ? t.unknown : dobLabel,
                    ),
                    _Row(label: t.placeOfBirth, value: draft.placeOfBirth),
                    _Row(label: t.nationality, value: draft.nationality),
                    _Row(label: t.regionLabel, value: regionLabel),
                    _Row(label: t.votingCenterLabel, value: centerLabel),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: t.registrationSectionDocumentVerification,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: t.documentType, value: docLabel),
                    if (validation != null) ...[
                      _Row(
                        label: t.status,
                        value: validation.ok ? t.ok : t.failed,
                      ),
                      _Row(
                        label: t.summaryLabel,
                        value: validation.summary.isEmpty
                            ? t.unknown
                            : validation.summary,
                      ),
                      _Row(
                        label: t.nameMatchLabel,
                        value: validation.nameOk ? t.yes : t.no,
                      ),
                      _Row(
                        label: t.dobMatchLabel,
                        value: validation.dobOk ? t.yes : t.no,
                      ),
                      _Row(
                        label: t.pobMatchLabel,
                        value: validation.pobOk ? t.yes : t.no,
                      ),
                      _Row(
                        label: t.nationalityMatchLabel,
                        value: validation.nationalityOk ? t.yes : t.no,
                      ),
                    ],
                    if (extracted != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        t.ocrExtractedTitle,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      _Row(
                        label: t.nameLabel,
                        value: extracted.fullName ?? t.unknown,
                      ),
                      _Row(
                        label: t.dateOfBirthShort,
                        value: extracted.dateOfBirth == null
                            ? t.unknown
                            : _formatDate(context, extracted.dateOfBirth),
                      ),
                      _Row(
                        label: t.placeOfBirthShort,
                        value: extracted.placeOfBirth ?? t.unknown,
                      ),
                      _Row(
                        label: t.nationality,
                        value: extracted.nationality ?? t.unknown,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: t.registrationSectionSecurityEnrollment,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(
                      label: t.biometricsLabel,
                      value: enrollment.biometricEnrolled
                          ? t.statusEnrolled
                          : t.statusPending,
                    ),
                    _Row(
                      label: t.livenessLabel,
                      value: enrollment.livenessVerified
                          ? t.statusVerified
                          : t.statusPending,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: CheckboxListTile(
                  value: _consent,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                  title: Text(t.registrationConsentTitle),
                  subtitle: Text(t.registrationConsentSubtitle),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: submission.isLoading || !canSubmit
                    ? null
                    : () => _submit(context),
                child: Text(
                  submission.isLoading
                      ? (_renewing
                          ? t.registrationRenewing
                          : t.registrationSubmitting)
                      : t.registrationSubmit,
                ),
              ),
              if (!widget.payload.isVerified || !enrollment.isComplete) ...[
                const SizedBox(height: 10),
                Text(
                  t.registrationSubmitBlockedNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final draft = ref.read(voterRegistrationDraftProvider);
    final enrollment = ref.read(registrationEnrollmentProvider);
    final validation = widget.payload.validation;
    final extracted = widget.payload.extracted;

    if (!draft.isValidBasicInfo || !enrollment.isComplete) return;

    final submission = RegistrationSubmission(
      fullName: draft.fullName,
      dateOfBirth: draft.dateOfBirth!,
      placeOfBirth: draft.placeOfBirth,
      nationality: draft.nationality,
      regionCode: draft.regionCode,
      documentType: widget.payload.docType.name,
      ocrRawText: extracted?.rawText,
      ocrSummary: validation?.summary,
      ocrNameOk: validation?.nameOk ?? false,
      ocrDobOk: validation?.dobOk ?? false,
      ocrPobOk: validation?.pobOk ?? false,
      ocrNationalityOk: validation?.nationalityOk ?? false,
      biometricEnrolled: enrollment.biometricEnrolled,
      livenessVerified: enrollment.livenessVerified,
      enrollmentCompletedAt: enrollment.completedAt,
      preferredCenterId: draft.preferredCenter?.id,
    );

    final result = await ref
        .read(registrationSubmissionProvider.notifier)
        .submit(submission);

    if (result == null || result.status == 'error') {
      if (!context.mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result?.message.isNotEmpty == true
                ? result!.message
                : t.registrationSubmissionFailed,
          ),
        ),
      );
      return;
    }

    final action = result.nextAction.trim().toLowerCase();
    final status = result.status.trim().toLowerCase();
    final cardExpired = result.cardExpired == true;
    final alreadyRenewed = _isRenewed(action, status);

    if (_isDeletedAccountActive(action, status, cardExpired)) {
      if (!context.mounted) return;
      final t = AppLocalizations.of(context);
      await _showExistingAccountDialog(
        context,
        title: t.deletedAccountLoginTitle,
        message: t.deletedAccountLoginBody,
      );
      if (!context.mounted) return;
      context.go('${RoutePaths.authLogin}?role=voter');
      return;
    }

    if (_isDeletedAccountExpired(action, status, cardExpired) && !alreadyRenewed) {
      if (!context.mounted) return;
      await _handleRenewal(context, submission, result);
      return;
    }

    if (_isDeletedAccountExpired(action, status, cardExpired) && alreadyRenewed) {
      if (!context.mounted) return;
      final t = AppLocalizations.of(context);
      await _showExistingAccountDialog(
        context,
        title: t.deletedAccountRenewedTitle,
        message: t.deletedAccountRenewedBody,
      );
      if (!context.mounted) return;
      context.go('${RoutePaths.authLogin}?role=voter');
      return;
    }

    if (result.registrationId.isNotEmpty) {
      await ref
          .read(deviceAccountPolicyProvider)
          .addAccountId(result.registrationId);
    }

    if (!context.mounted) return;
    context.push(RoutePaths.voterRegistrationSubmitted, extra: result);
  }

  bool _isRenewed(String action, String status) {
    return action == 'renewed' || status == 'renewed';
  }

  bool _isDeletedAccountActive(
    String action,
    String status,
    bool cardExpired,
  ) {
    if (cardExpired) return false;
    return action == 'redirect_login' ||
        action == 'use_existing_account' ||
        status == 'account_deleted_active' ||
        status == 'deleted_active' ||
        status == 'existing_account_active';
  }

  bool _isDeletedAccountExpired(
    String action,
    String status,
    bool cardExpired,
  ) {
    if (cardExpired) return true;
    return action == 'renew_and_login' ||
        status == 'account_deleted_expired' ||
        status == 'deleted_expired' ||
        status == 'existing_account_expired';
  }

  Future<void> _handleRenewal(
    BuildContext context,
    RegistrationSubmission submission,
    RegistrationSubmissionResult result,
  ) async {
    if (mounted) {
      setState(() => _renewing = true);
    }
    final renewalResult = await ref
        .read(registrationSubmissionProvider.notifier)
        .renew(
          submission,
          existingRegistrationId: result.existingRegistrationId,
          renewalToken: result.renewalToken,
        );
    if (mounted) {
      setState(() => _renewing = false);
    }

    if (renewalResult == null || renewalResult.status == 'error') {
      if (!context.mounted) return;
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            renewalResult?.message.isNotEmpty == true
                ? renewalResult!.message
                : t.registrationRenewalFailed,
          ),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    final t = AppLocalizations.of(context);
    await _showExistingAccountDialog(
      context,
      title: t.deletedAccountRenewedTitle,
      message: t.deletedAccountRenewedBody,
    );
    if (!context.mounted) return;
    context.go('${RoutePaths.authLogin}?role=voter');
  }

  Future<void> _showExistingAccountDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final t = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.continueToLogin),
          ),
        ],
      ),
    );
  }

  String _docLabel(AppLocalizations t, OfficialDocumentType type) {
    return switch (type) {
      OfficialDocumentType.nationalId => t.documentTypeNationalId,
      OfficialDocumentType.passport => t.documentTypePassport,
      OfficialDocumentType.other => t.documentTypeOther,
    };
  }

  String _regionLabel(AppLocalizations t, String code) {
    return switch (code) {
      'AD' => t.regionAdamawa,
      'CE' => t.regionCentre,
      'ES' => t.regionEast,
      'EN' => t.regionFarNorth,
      'LT' => t.regionLittoral,
      'NO' => t.regionNorth,
      'NW' => t.regionNorthWest,
      'SU' => t.regionSouth,
      'SW' => t.regionSouthWest,
      'OU' => t.regionWest,
      _ => code.isEmpty ? t.unknown : code,
    };
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return '';
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
