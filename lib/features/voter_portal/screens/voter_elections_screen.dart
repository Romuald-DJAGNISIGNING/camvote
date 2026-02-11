import 'package:camvote/core/errors/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../domain/election.dart';
import '../providers/voter_portal_providers.dart';

class VoterElectionsScreen extends ConsumerWidget {
  const VoterElectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final electionsAsync = ref.watch(voterElectionsProvider);

    return Scaffold(
      body: electionsAsync.when(
        loading: () => const Center(child: CamElectionLoader()),
        error: (e, _) => Center(child: Text(safeErrorMessage(context, e))),
        data: (elections) {
          final sorted = [...elections]
            ..sort((a, b) => a.opensAt.compareTo(b.opensAt));

          return BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.voterElections,
                        subtitle: t.electionsBrowseSubtitle,
                      ),
                      const SizedBox(height: 16),
                      ...sorted.map((e) {
                        final status = e.status;
                        final label = switch (status) {
                          ElectionStatus.upcoming => t.electionStatusUpcoming,
                          ElectionStatus.open => t.electionStatusOpen,
                          ElectionStatus.closed => t.electionStatusClosed,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _showElection(context, t, e),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withAlpha(18),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.how_to_vote_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            e.scopeLabel,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            t.candidatesCountLabel(
                                              e.candidates.length,
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusChip(status: status, label: label),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showElection(BuildContext context, AppLocalizations t, Election e) {
    final opensLabel = _formatDateTime(context, e.opensAt);
    final closesLabel = _formatDateTime(context, e.closesAt);
    showModalBottomSheet<void>(
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
                e.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(t.electionScopeLabel(e.scopeLabel)),
              const SizedBox(height: 8),
              Text('${t.opensLabel}: $opensLabel'),
              Text('${t.closesLabel}: $closesLabel'),
              const SizedBox(height: 12),
              CamSectionHeader(
                title: t.candidatesLabel,
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 4),
              ...e.candidates.map(
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
    );
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date $time';
  }
}

class _StatusChip extends StatelessWidget {
  final ElectionStatus status;
  final String label;

  const _StatusChip({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (status) {
      ElectionStatus.upcoming => cs.tertiary,
      ElectionStatus.open => cs.primary,
      ElectionStatus.closed => cs.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}


