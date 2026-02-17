import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';

class VoteImpactTally {
  const VoteImpactTally({
    required this.before,
    required this.delta,
    required this.after,
  });

  final int before;
  final int delta;
  final int after;
}

class VoterVoteImpactScreen extends StatefulWidget {
  const VoterVoteImpactScreen({
    super.key,
    required this.electionTitle,
    required this.candidateName,
    this.tally,
  });

  final String electionTitle;
  final String candidateName;
  final VoteImpactTally? tally;

  @override
  State<VoterVoteImpactScreen> createState() => _VoterVoteImpactScreenState();
}

class _VoterVoteImpactScreenState extends State<VoterVoteImpactScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..forward();
  Timer? _autoExitTimer;

  @override
  void initState() {
    super.initState();
    _autoExitTimer = Timer(const Duration(milliseconds: 2350), () {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  @override
  void dispose() {
    _autoExitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tally = widget.tally;
    final hasTally = tally != null && tally.after >= 0;

    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _controller,
                            curve: Curves.easeOutBack,
                          ),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: BrandPalette.heroGradient,
                              boxShadow: BrandPalette.softShadow,
                            ),
                            alignment: Alignment.center,
                            child: const CamVoteLogo(size: 48),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          t.voteAction,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasTally
                              ? t.voteImpactAddedLive
                              : t.voteImpactRecorded,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.candidateName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 18),
                        if (hasTally) ...[
                          _ImpactRow(
                            label: t.voteImpactPreviousTotal,
                            value: tally.before,
                          ),
                          const SizedBox(height: 8),
                          _ImpactRow(
                            label: t.voteImpactYourContribution,
                            value: tally.delta,
                          ),
                          const SizedBox(height: 8),
                          _ImpactRow(
                            label: t.voteImpactNewLiveTotal,
                            value: tally.after,
                            emphasize: true,
                          ),
                          const SizedBox(height: 10),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 1100),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(999),
                              );
                            },
                          ),
                        ] else ...[
                          const SizedBox(height: 6),
                          const CircularProgressIndicator(strokeWidth: 2.8),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          widget.electionTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final int value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
      color: emphasize ? Theme.of(context).colorScheme.primary : null,
    );

    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) {
            return Text(animated.round().toString(), style: style);
          },
        ),
      ],
    );
  }
}
