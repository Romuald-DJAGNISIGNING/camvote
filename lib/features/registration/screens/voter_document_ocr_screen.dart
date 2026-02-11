import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/widgets/loaders/camvote_pulse_loading.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/motion/cam_reveal.dart';
import '../domain/registration_identity.dart';
import '../domain/registration_review_payload.dart';
import '../providers/registration_ocr_controller.dart';
import '../providers/registration_providers.dart';
import '../services/ocr/ocr_models.dart';
import '../services/ocr/ocr_summary.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../../core/theme/role_theme.dart';

class VoterDocumentOcrScreen extends ConsumerWidget {
  final RegistrationIdentity expected;

  const VoterDocumentOcrScreen({super.key, required this.expected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final s = ref.watch(registrationOcrControllerProvider);
    final c = ref.read(registrationOcrControllerProvider.notifier);
    final enrollment = ref.watch(registrationEnrollmentProvider);

    final extracted = s.extracted;
    final validation = s.validation;

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.documentOcrTitle)),
      body: Stack(
        children: [
          BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.documentOcrTitle,
                        subtitle: t.documentOcrSubtitle,
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<OfficialDocumentType>(
                        initialValue: s.docType,
                        decoration: InputDecoration(
                          labelText: t.documentType,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: OfficialDocumentType.nationalId,
                            child: Text(t.documentTypeNationalId),
                          ),
                          DropdownMenuItem(
                            value: OfficialDocumentType.passport,
                            child: Text(t.documentTypePassport),
                          ),
                          DropdownMenuItem(
                            value: OfficialDocumentType.other,
                            child: Text(t.documentTypeOther),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) c.setDocType(v);
                        },
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  (kIsWeb || s.status == OcrStatus.processing)
                                  ? null
                                  : c.pickFromGallery,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(t.pickFromGallery),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  (kIsWeb || s.status == OcrStatus.processing)
                                  ? null
                                  : c.captureWithCamera,
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: Text(t.captureWithCamera),
                            ),
                          ),
                        ],
                      ),

                      if (kIsWeb) ...[
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: t.ocrNotSupportedTitle,
                          message: t.ocrNotSupportedMessage,
                          icon: Icons.info_outline,
                        ),
                      ],

                      if (s.pickedImage != null && !kIsWeb) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(s.pickedImage!.path),
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      if (s.error != null) ...[
                        _InfoCard(
                          title: t.ocrFailedTitle,
                          message: s.error!,
                          icon: Icons.error_outline,
                        ),
                        const SizedBox(height: 12),
                      ],

                      FilledButton.icon(
                        onPressed:
                            (kIsWeb ||
                                s.pickedImage == null ||
                                s.status == OcrStatus.processing)
                            ? null
                            : () async {
                                await c.runOcrAndValidate(expected);
                                if (!context.mounted) return;
                                final st = ref.read(
                                  registrationOcrControllerProvider,
                                );
                                final v = st.validation;
                                final currentExtracted = st.extracted;
                                if (v == null) return;

                                final dob = currentExtracted?.dateOfBirth;
                                if (dob != null &&
                                    _ageInYears(dob, DateTime.now()) < 18) {
                                  await _showUnderageDialog(context);
                                  if (!context.mounted) return;
                                  ref
                                      .read(currentRoleProvider.notifier)
                                      .setRole(AppRole.public);
                                  context.go(RoutePaths.publicHome);
                                  return;
                                }

                                if (!v.ok) {
                                  if (isForeignDocument(v)) {
                                    await _showForeignDialog(context);
                                    if (!context.mounted) return;
                                    ref
                                        .read(currentRoleProvider.notifier)
                                        .setRole(AppRole.public);
                                    context.go(RoutePaths.publicHome);
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${t.ocrRejected}: '
                                        '${buildOcrSummary(t, validation: v, extracted: currentExtracted)}',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(t.ocrVerified)),
                                  );
                                }
                              },
                        icon: s.status == OcrStatus.processing
                            ? const CamElectionLoader(size: 18, strokeWidth: 2)
                            : const Icon(Icons.document_scanner_outlined),
                        label: Text(
                          s.status == OcrStatus.processing
                              ? t.ocrProcessing
                              : t.runOcr,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (extracted != null) ...[
                        _SectionTitle(title: t.ocrExtractedTitle),
                        const SizedBox(height: 10),
                        _KeyValue(label: t.fullName, value: extracted.fullName),
                        _KeyValue(
                          label: t.dateOfBirth,
                          value: extracted.dateOfBirth?.toIso8601String(),
                        ),
                        _KeyValue(
                          label: t.placeOfBirth,
                          value: extracted.placeOfBirth,
                        ),
                        _KeyValue(
                          label: t.nationality,
                          value: extracted.nationality,
                        ),
                        const SizedBox(height: 10),
                        ExpansionTile(
                          title: Text(t.rawOcrText),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(extracted.rawText),
                            ),
                          ],
                        ),
                      ],

                      if (validation != null) ...[
                        const SizedBox(height: 16),
                        _SectionTitle(title: t.ocrValidationTitle),
                        const SizedBox(height: 10),
                        _ValidationRow(
                          label: t.fullName,
                          ok: validation.nameOk,
                        ),
                        _ValidationRow(
                          label: t.dateOfBirth,
                          ok: validation.dobOk,
                        ),
                        _ValidationRow(
                          label: t.placeOfBirth,
                          ok: validation.pobOk,
                        ),
                        if ((extracted?.nationality ?? '').trim().isNotEmpty)
                          _ValidationRow(
                            label: t.nationality,
                            ok: validation.nationalityOk,
                          ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: validation.ok
                              ? t.ocrVerifiedTitle
                              : t.ocrRejectedTitle,
                          message: buildOcrSummary(
                            t,
                            validation: validation,
                            extracted: extracted,
                          ),
                          icon: validation.ok
                              ? Icons.verified_outlined
                              : Icons.gpp_bad_outlined,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => c.reset(),
                                child: Text(t.tryAnotherDoc),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: validation.ok
                                    ? () async {
                                        final payload =
                                            RegistrationReviewPayload(
                                              identity: expected,
                                              docType: s.docType,
                                              extracted: extracted,
                                              validation: validation,
                                            );

                                        final done = await context.push<bool>(
                                          RoutePaths.voterBiometricEnrollment,
                                          extra: payload,
                                        );
                                        if (done == true && context.mounted) {
                                          context.push(
                                            RoutePaths.voterRegistrationReview,
                                            extra: payload,
                                          );
                                        }
                                      }
                                    : null,
                                child: Text(t.continueNext),
                              ),
                            ),
                          ],
                        ),
                        if (validation.ok) ...[
                          const SizedBox(height: 12),
                          CamReveal(
                            child: _InfoCard(
                              title: enrollment.isComplete
                                  ? t.enrollmentCompleteTitle
                                  : t.enrollmentInProgressTitle,
                              message: enrollment.isComplete
                                  ? t.enrollmentCompleteBody
                                  : t.enrollmentInProgressBody,
                              icon: enrollment.isComplete
                                  ? Icons.verified_outlined
                                  : Icons.security_outlined,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (s.status == OcrStatus.processing)
            Positioned.fill(
              child: CamVoteLoadingOverlay(
                title: t.ocrProcessing,
                subtitle: t.documentOcrSubtitle,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final Object? value;
  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value?.toString() ?? t.unknown),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final String label;
  final bool ok;
  const _ValidationRow({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(ok ? Icons.check_circle_outline : Icons.cancel_outlined),
      title: Text(label),
      trailing: Text(ok ? t.ok : t.no),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showForeignDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.foreignDocumentTitle),
      content: Text(t.foreignDocumentBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.close),
        ),
      ],
    ),
  );
}

int _ageInYears(DateTime dob, DateTime now) {
  var age = now.year - dob.year;
  final hadBirthday =
      (now.month > dob.month) || (now.month == dob.month && now.day >= dob.day);
  if (!hadBirthday) age -= 1;
  return age;
}

Future<void> _showUnderageDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.underageRegistrationTitle),
      content: Text(t.underageRegistrationBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.close),
        ),
      ],
    ),
  );
}
