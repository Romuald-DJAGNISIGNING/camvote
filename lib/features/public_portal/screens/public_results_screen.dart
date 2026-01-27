import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../providers/public_portal_providers.dart';
import '../models/public_models.dart';
import '../widgets/results_charts.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../utils/candidate_metric.dart';
import '../widgets/results_region_map_card.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';

class PublicResultsScreen extends ConsumerWidget {
  const PublicResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final state = ref.watch(publicResultsProvider);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.publicResultsTitle)),
      body: BrandBackdrop(
        child: state.when(
          loading: () => const Center(child: CamElectionLoader()),
          error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
          data: (data) {
            final cs = Theme.of(context).colorScheme;

            final chartCandidates = data.candidates.map((c) {
              return CandidateMetric(
                id: c.candidateId,
                name: c.candidateName,
                votes: c.votes,
                color: _colorForCandidate(c.candidateName, cs),
              );
            }).toList();

            final labelsByCode = {
              'far_north': t.regionFarNorth,
              'north': t.regionNorth,
              'adamawa': t.regionAdamawa,
              'north_west': t.regionNorthWest,
              'west': t.regionWest,
              'centre': t.regionCentre,
              'littoral': t.regionLittoral,
              'south_west': t.regionSouthWest,
              'east': t.regionEast,
              'south': t.regionSouth,
            };

            return ResponsiveContent(
              child: SingleChildScrollView(
                child: CamStagger(
                  padding: EdgeInsets.zero,
                  children: [
                    BrandHeader(
                      title:
                          data.electionTitle.isEmpty ? t.publicResultsTitle : data.electionTitle,
                      subtitle: data.electionClosed
                          ? t.resultsFinal
                          : t.resultsLive,
                    ),
                    const SizedBox(height: 14),
                    _KpiRow(
                      turnout: data.turnoutRate,
                      registered: data.totalRegistered,
                      votes: data.totalVotesCast,
                    ),
                    const SizedBox(height: 14),
                    ResultsRegionMapCard(
                      winners: data.regionalWinners,
                      labelsByRegionCode: labelsByCode,
                      title: t.mapTitle,
                      subtitle: t.mapTapHint,
                      nationalWinnerName: _nationalWinnerName(chartCandidates),
                    ),
                    const SizedBox(height: 14),
                    ResultsCharts(
                      candidates: chartCandidates,
                      turnoutTrend: data.turnoutTrend,
                      watermarkTitle: t.appName,
                      watermarkSubtitle: t.slogan,
                    ),
                    const SizedBox(height: 14),
                    _CandidatesList(results: data.candidates),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _colorForCandidate(String name, ColorScheme cs) {
    final palette = [
      const Color(0xFF0A7D2E),
      const Color(0xFFC62828),
      const Color(0xFFF9A825),
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
    ];
    final idx = name.hashCode.abs() % palette.length;
    return palette[idx].withAlpha(230);
  }

  String _nationalWinnerName(List<CandidateMetric> candidates) {
    if (candidates.isEmpty) return '';
    final sorted = [...candidates]..sort((a, b) => b.votes.compareTo(a.votes));
    return sorted.first.name;
  }

}

class _KpiRow extends StatelessWidget {
  final double turnout;
  final int registered;
  final int votes;

  const _KpiRow({
    required this.turnout,
    required this.registered,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: t.turnout,
            value: turnout,
            decimals: 1,
            suffix: '%',
            icon: Icons.track_changes_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: t.totalRegistered,
            value: registered,
            icon: Icons.people_alt_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            label: t.totalVotesCast,
            value: votes,
            icon: Icons.how_to_vote_outlined,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final num value;
  final int decimals;
  final String suffix;
  final IconData? icon;

  const _KpiCard({
    required this.label,
    required this.value,
    this.decimals = 0,
    this.suffix = '',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final factor = decimals <= 0 ? 1 : math.pow(10, decimals).toInt();
    final scaledValue = (value * factor).round();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: cs.primary),
              ),
              const SizedBox(height: 6),
            ],
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            DefaultTextStyle(
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ) ??
                      const TextStyle(),
              child: CamCountUp(
                value: scaledValue,
                format: (v) {
                  if (decimals <= 0) return '${_fmt(v)}$suffix';
                  final scaled = v / factor;
                  return '${scaled.toStringAsFixed(decimals)}$suffix';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      b.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) b.write(',');
    }
    return b.toString();
  }
}

class _CandidatesList extends StatelessWidget {
  final List<CandidateLiveResult> results;
  const _CandidatesList({required this.results});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (results.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t.noData,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    return Column(
      children: results.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ListTile(
              title: Text(
                r.candidateName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(r.partyName),
              trailing: Text('${r.percent.toStringAsFixed(1)}%'),
            ),
          ),
        );
      }).toList(),
    );
  }
}
