import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/qr/branded_qr_code.dart';
import '../../../shared/security/hash_utils.dart';
import '../../registration/providers/registration_providers.dart';
import '../../registration/models/registration_draft.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class VoterCardScreen extends ConsumerStatefulWidget {
  const VoterCardScreen({super.key});

  @override
  ConsumerState<VoterCardScreen> createState() => _VoterCardScreenState();
}

class _VoterCardScreenState extends ConsumerState<VoterCardScreen> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final draft = ref.watch(voterRegistrationDraftProvider);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.electoralCardTitle),
        showBell: false,
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.electoralCardTitle,
                    subtitle: t.electoralCardSubtitle,
                  ),
                  const SizedBox(height: 12),
                  if (!draft.isValidBasicInfo)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_outlined),
                        title: Text(t.electoralCardIncompleteNote),
                      ),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _unlocked
                            ? _CardDetails(draft: draft)
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_outline),
                                      const SizedBox(width: 8),
                                      Text(
                                        t.electoralCardLockedTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(t.electoralCardLockedSubtitle),
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    onPressed: _unlock,
                                    icon: const Icon(Icons.lock_open_outlined),
                                    label: Text(t.verifyToUnlock),
                                  ),
                                ],
                              ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    final t = AppLocalizations.of(context);
    final bio = BiometricGate();
    final supported = await bio.isSupported();
    if (!supported) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricNotAvailable)));
      return;
    }
    final bioOk = await bio.requireBiometric(
      reason: t.electoralCardBiometricReason,
    );
    if (!bioOk) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricVerificationFailed)));
      return;
    }

    if (!mounted) return;
    final liveOk = await LivenessChallengeScreen.run(context);
    if (!liveOk) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.livenessCheckFailed)));
      return;
    }

    if (mounted) {
      setState(() => _unlocked = true);
    }
  }
}

class _CardDetails extends StatelessWidget {
  final RegistrationDraft draft;
  const _CardDetails({required this.draft});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dobLabel = _formatDate(context, draft.dateOfBirth);
    final regionLabel = _regionLabel(t, draft.regionCode);
    final centerLabel = draft.preferredCenter?.name.trim() ?? '';
    final cardId = HashUtils.sha256Hex(
      '${draft.fullName}|${draft.dateOfBirth?.toIso8601String() ?? ''}|${draft.regionCode}|${draft.email}',
    ).substring(0, 18).toUpperCase();
    final qrData = [
      'CAMVOTE_CARD',
      cardId,
      draft.fullName,
      draft.regionCode,
      draft.preferredCenter?.id ?? '',
    ].join('|');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                cs.primary.withAlpha(235),
                cs.tertiary.withAlpha(210),
                cs.primaryContainer.withAlpha(220),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withAlpha(45),
                blurRadius: 20,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HeroChip(
                    icon: Icons.verified_user_outlined,
                    label: t.statusVerified,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white.withAlpha(235),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                t.electoralCardTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withAlpha(220),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                draft.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${t.trackingIdLabel}: $cardId',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(210),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroChip(icon: Icons.map_outlined, label: regionLabel),
                  if (draft.nationality.trim().isNotEmpty)
                    _HeroChip(
                      icon: Icons.flag_outlined,
                      label: draft.nationality,
                    ),
                  if (centerLabel.isNotEmpty)
                    _HeroChip(icon: Icons.place_outlined, label: centerLabel),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final vertical = constraints.maxWidth < 620;
            final details = Column(
              children: [
                _InfoTile(label: t.fullName, value: draft.fullName),
                _InfoTile(
                  label: t.dateOfBirth,
                  value: dobLabel.isEmpty ? t.unknown : dobLabel,
                ),
                _InfoTile(label: t.regionLabel, value: regionLabel),
                _InfoTile(label: t.placeOfBirth, value: draft.placeOfBirth),
                _InfoTile(
                  label: t.votingCenterLabel,
                  value: centerLabel.isEmpty ? t.unknown : centerLabel,
                ),
                _InfoTile(
                  label: t.nationality,
                  value: draft.nationality.trim().isEmpty
                      ? t.unknown
                      : draft.nationality,
                ),
              ],
            );
            final qrPanel = Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant.withAlpha(90)),
              ),
              child: Column(
                children: [
                  BrandedQrCode(data: qrData, size: 170, animatedFrame: true),
                  const SizedBox(height: 12),
                  Text(
                    t.electoralCardQrNote,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );

            if (vertical) {
              return Column(
                children: [details, const SizedBox(height: 12), qrPanel],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: details),
                const SizedBox(width: 14),
                SizedBox(width: 240, child: qrPanel),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        CamReveal(
          child: Text(
            '${t.status}: ${t.statusVerified}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(BuildContext context, DateTime? dob) {
    if (dob == null) return '';
    return MaterialLocalizations.of(context).formatMediumDate(dob);
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
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(70),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface.withAlpha(165),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? t.unknown : value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
