import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../registration/providers/registration_providers.dart';
import '../../registration/models/registration_draft.dart';

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
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.electoralCardTitle),
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
    final dobLabel = _formatDate(context, draft.dateOfBirth);
    final regionLabel = _regionLabel(t, draft.regionCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.electoralCardTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        _Row(label: t.fullName, value: draft.fullName),
        _Row(
          label: t.dateOfBirth,
          value: dobLabel.isEmpty ? t.unknown : dobLabel,
        ),
        _Row(label: t.regionLabel, value: regionLabel),
        _Row(label: t.placeOfBirth, value: draft.placeOfBirth),
        if (draft.nationality.trim().isNotEmpty)
          _Row(label: t.nationality, value: draft.nationality),
        const SizedBox(height: 16),
        Center(
          child: QrImageView(
            data:
                'CAMVOTE|${draft.fullName}|${draft.dateOfBirth}|${draft.regionCode}',
            size: 160,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t.electoralCardQrNote,
          style: Theme.of(context).textTheme.bodySmall,
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

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(value.isEmpty ? t.unknown : value),
        ],
      ),
    );
  }
}
