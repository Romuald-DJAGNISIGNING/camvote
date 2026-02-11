import 'package:camvote/core/errors/error_message.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/camvote_pulse_loading.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../core/routing/route_paths.dart';
import '../domain/election.dart';
import '../providers/voter_portal_providers.dart';

class VoterHomeScreen extends ConsumerWidget {
  const VoterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);

    final electionsAsync = ref.watch(voterElectionsProvider);

    return electionsAsync.when(
      loading: () => BrandBackdrop(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CamVotePulseLoading(
              title: t.loading,
              subtitle: t.voterHomeSubtitle,
              compact: true,
            ),
          ),
        ),
      ),
      error: (e, _) => Center(child: Text(safeErrorMessage(context, e))),
      data: (elections) {
        final upcoming =
            elections.where((e) => e.status == ElectionStatus.upcoming).toList()
              ..sort((a, b) => a.opensAt.compareTo(b.opensAt));

        final next = upcoming.isEmpty ? null : upcoming.first;

        return BrandBackdrop(
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CamStagger(
                  children: [
                    const SizedBox(height: 6),
                    BrandHeader(
                      title: t.voterPortalTitle,
                      subtitle: t.voterHomeSubtitle,
                    ),
                    const SizedBox(height: 16),
                    if (next != null) _NextElectionCard(election: next),
                    if (next != null) const SizedBox(height: 16),
                    _QuickActions(
                      onGoElections: () =>
                          ref.read(voterTabIndexProvider.notifier).setIndex(1),
                      onGoVote: () =>
                          ref.read(voterTabIndexProvider.notifier).setIndex(2),
                      onGoResults: () =>
                          ref.read(voterTabIndexProvider.notifier).setIndex(3),
                      onGoCountdowns: () =>
                          context.push(RoutePaths.voterCountdowns),
                    ),
                    const SizedBox(height: 24),
                    CamSectionHeader(
                      title: t.publicElectionsInfoTitle,
                      subtitle: t.publicElectionsInfoSub,
                      icon: Icons.info_outline,
                    ),
                    const SizedBox(height: 6),
                    ...elections.map((e) => _ElectionTile(election: e)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NextElectionCard extends StatefulWidget {
  final Election election;
  const _NextElectionCard({required this.election});

  @override
  State<_NextElectionCard> createState() => _NextElectionCardState();
}

class _NextElectionCardState extends State<_NextElectionCard> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final remaining = widget.election.timeUntilOpen;
    final safe = remaining.isNegative ? Duration.zero : remaining;

    String two(int n) => n.toString().padLeft(2, '0');
    final d = safe.inDays;
    final h = safe.inHours % 24;
    final m = safe.inMinutes % 60;
    final s = safe.inSeconds % 60;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              BrandPalette.heroGradient.colors.first.withAlpha(40),
              BrandPalette.heroGradient.colors.last.withAlpha(30),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.how_to_vote_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.nextElectionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.election.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CountdownPill(
                        label: t.nextElectionCountdownLabelDays,
                        value: d.toString(),
                      ),
                      _CountdownPill(
                        label: t.nextElectionCountdownLabelHours,
                        value: two(h),
                      ),
                      _CountdownPill(
                        label: t.nextElectionCountdownLabelMinutes,
                        value: two(m),
                      ),
                      _CountdownPill(
                        label: t.nextElectionCountdownLabelSeconds,
                        value: two(s),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onGoElections;
  final VoidCallback onGoVote;
  final VoidCallback onGoResults;
  final VoidCallback onGoCountdowns;

  const _QuickActions({
    required this.onGoElections,
    required this.onGoVote,
    required this.onGoResults,
    required this.onGoCountdowns,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 720;
        final spacing = wide ? 12.0 : 8.0;
        final count = 4;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              [
                _QuickActionTile(
                  title: t.voterElections,
                  icon: Icons.ballot_outlined,
                  onTap: onGoElections,
                ),
                _QuickActionTile(
                  title: t.voterVote,
                  icon: Icons.verified_user_outlined,
                  onTap: onGoVote,
                  accent: Theme.of(context).colorScheme.primary,
                ),
                _QuickActionTile(
                  title: t.voterResults,
                  icon: Icons.query_stats_outlined,
                  onTap: onGoResults,
                ),
                _QuickActionTile(
                  title: t.voterCountdowns,
                  icon: Icons.timer_outlined,
                  onTap: onGoCountdowns,
                  accent: Theme.of(context).colorScheme.tertiary,
                ),
              ].map((tile) {
                return SizedBox(
                  width: wide
                      ? (c.maxWidth - spacing * (count - 1)) / count
                      : c.maxWidth,
                  child: tile,
                );
              }).toList(),
        );
      },
    );
  }
}

class _ElectionTile extends StatelessWidget {
  final Election election;
  const _ElectionTile({required this.election});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final status = election.status;
    final icon = switch (status) {
      ElectionStatus.upcoming => Icons.schedule,
      ElectionStatus.open => Icons.play_circle_outline,
      ElectionStatus.closed => Icons.lock_outline,
    };
    final label = switch (status) {
      ElectionStatus.upcoming => t.electionStatusUpcoming,
      ElectionStatus.open => t.electionStatusOpen,
      ElectionStatus.closed => t.electionStatusClosed,
    };

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(election.title),
        subtitle: Text('${election.scopeLabel} • $label'),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    election.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(t.electionScopeLabel(election.scopeLabel)),
                  const SizedBox(height: 8),
                  Text(t.candidatesCountLabel(election.candidates.length)),
                  const SizedBox(height: 12),
                  ...election.candidates.map(
                    (c) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(c.fullName),
                        subtitle: Text('${c.partyAcronym} • ${c.partyName}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.accent,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = accent ?? cs.secondary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(140),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
