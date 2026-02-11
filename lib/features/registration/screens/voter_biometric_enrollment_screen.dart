import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/widgets/loaders/camvote_pulse_loading.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../core/motion/cam_reveal.dart';
import '../domain/registration_review_payload.dart';
import '../providers/registration_providers.dart';

class VoterBiometricEnrollmentScreen extends ConsumerStatefulWidget {
  final RegistrationReviewPayload? payload;

  const VoterBiometricEnrollmentScreen({super.key, this.payload});

  @override
  ConsumerState<VoterBiometricEnrollmentScreen> createState() =>
      _VoterBiometricEnrollmentScreenState();
}

class _VoterBiometricEnrollmentScreenState
    extends ConsumerState<VoterBiometricEnrollmentScreen> {
  bool _isRunningAction = false;
  String? _loadingTitle;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(registrationEnrollmentProvider.notifier).loadEnrollment(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final enrollment = ref.watch(registrationEnrollmentProvider);
    final enrollCheck = BiometricGate().hasEnrolledBiometrics();
    final name = widget.payload?.identity.fullName.trim();
    final subtitle = name == null || name.isEmpty
        ? t.biometricEnrollmentSubtitle
        : t.biometricEnrollmentSubtitleWithName(name);

    final progress = enrollment.isComplete
        ? 1.0
        : enrollment.biometricEnrolled || enrollment.livenessVerified
        ? 0.5
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.biometricEnrollmentTitle),
      ),
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
                        title: t.biometricEnrollmentTitle,
                        subtitle: subtitle,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<bool>(
                        future: enrollCheck,
                        builder: (context, snapshot) {
                          final hasEnrolled = snapshot.data ?? false;
                          final label = hasEnrolled
                              ? t.reverifyBiometrics
                              : t.enrollNow;
                          return _EnrollmentStepCard(
                            title: t.biometricEnrollmentStep1Title,
                            subtitle: t.biometricEnrollmentStep1Subtitle,
                            icon: Icons.fingerprint,
                            complete: enrollment.biometricEnrolled,
                            buttonLabel: label,
                            onAction: () => _handleBiometric(context),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _EnrollmentStepCard(
                        title: t.biometricEnrollmentStep2Title,
                        subtitle: t.biometricEnrollmentStep2Subtitle,
                        icon: Icons.face_retouching_natural,
                        complete: enrollment.livenessVerified,
                        buttonLabel: enrollment.livenessVerified
                            ? t.reverifyLiveness
                            : t.runLiveness,
                        onAction: () => _handleLiveness(context),
                      ),
                      const SizedBox(height: 16),
                      CamReveal(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  enrollment.isComplete
                                      ? t.enrollmentCompleteTitle
                                      : t.enrollmentInProgressTitle,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const CamElectionLoader(
                                      size: 18,
                                      strokeWidth: 2.4,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${(progress * 100).round()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  enrollment.isComplete
                                      ? t.enrollmentCompleteBody
                                      : t.enrollmentInProgressBody,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: enrollment.isComplete
                                      ? () => Navigator.of(context).pop(true)
                                      : null,
                                  child: Text(t.finishEnrollment),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(t.biometricPrivacyNote),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isRunningAction)
            Positioned.fill(
              child: CamVoteLoadingOverlay(
                title: _loadingTitle ?? t.loading,
                subtitle: t.biometricEnrollmentSubtitle,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleBiometric(BuildContext context) async {
    if (mounted) {
      setState(() {
        _isRunningAction = true;
        _loadingTitle = AppLocalizations.of(context).biometricEnrollmentTitle;
      });
    }
    final t = AppLocalizations.of(context);
    final gate = BiometricGate();
    final enrolled = await gate.hasEnrolledBiometrics();
    final supported = await gate.isSupported();
    if (!mounted) return;
    if (!supported) {
      _toast(enrolled ? t.biometricNotAvailable : t.biometricEnrollRequired);
      if (mounted) {
        setState(() => _isRunningAction = false);
      }
      return;
    }

    final ok = await gate.requireBiometric(reason: t.biometricEnrollReason);
    if (!mounted) return;
    if (!ok) {
      _toast(t.biometricVerificationFailed);
      setState(() => _isRunningAction = false);
      return;
    }

    await ref
        .read(registrationEnrollmentProvider.notifier)
        .markBiometricEnrolled();
    if (!mounted) return;
    _toast(t.biometricEnrollmentRecorded);
    setState(() => _isRunningAction = false);
  }

  Future<void> _handleLiveness(BuildContext context) async {
    if (mounted) {
      setState(() {
        _isRunningAction = true;
        _loadingTitle = AppLocalizations.of(context).runLiveness;
      });
    }
    final t = AppLocalizations.of(context);
    final ok = await LivenessChallengeScreen.run(context);
    if (!mounted) return;
    if (!ok) {
      _toast(t.livenessCheckFailed);
      setState(() => _isRunningAction = false);
      return;
    }

    await ref
        .read(registrationEnrollmentProvider.notifier)
        .markLivenessVerified();
    if (!mounted) return;
    _toast(t.livenessVerifiedToast);
    setState(() => _isRunningAction = false);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EnrollmentStepCard extends StatelessWidget {
  const _EnrollmentStepCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.complete,
    required this.buttonLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool complete;
  final String buttonLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final badgeColor = complete
        ? cs.primaryContainer
        : cs.surfaceContainerHighest;
    final t = AppLocalizations.of(context);
    final badgeText = complete ? t.statusCompleted : t.statusRequired;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;
                final iconBox = Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: cs.primary),
                );
                final titleText = Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                );
                final badge = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          iconBox,
                          const SizedBox(width: 12),
                          Expanded(child: titleText),
                        ],
                      ),
                      const SizedBox(height: 8),
                      badge,
                    ],
                  );
                }

                return Row(
                  children: [
                    iconBox,
                    const SizedBox(width: 12),
                    Expanded(child: titleText),
                    badge,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Text(subtitle),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onAction, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
