import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../core/widgets/marketing/app_download_card.dart';
import '../../../core/theme/role_theme.dart';
import '../../public_portal/widgets/results_charts.dart';
import '../../public_portal/widgets/results_region_map_card.dart';
import '../../public_portal/providers/public_portal_providers.dart';
import '../../public_portal/utils/candidate_metric.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/admin_providers.dart';

class ObserverDashboardScreen extends ConsumerWidget {
  const ObserverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final results = ref.watch(publicResultsProvider);
    final auth = ref.watch(authControllerProvider).asData?.value;
    final isObserverAuthed =
        auth?.isAuthenticated == true && auth?.user?.role == AppRole.observer;
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.observerDashboard),
        actions: [
          if (isObserverAuthed)
            IconButton(
              tooltip: t.signOut,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (!context.mounted) return;
                context.go(RoutePaths.webPortal);
              },
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: stats.when(
        data: (s) {
          final data = results.asData?.value;
          final chartCandidates = data == null
              ? const <CandidateMetric>[]
              : data.candidates.map((c) {
                  return CandidateMetric(
                    id: c.candidateId,
                    name: c.candidateName,
                    votes: c.votes,
                    color: _colorForCandidate(c.candidateName),
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
          return BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.observerDashboard,
                        subtitle: t.observerDashboardHeaderSubtitle,
                      ),
                      const SizedBox(height: 12),
                      const AppDownloadCard(),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.visibility),
                          title: Text(t.observerReadOnlyTitle),
                          subtitle: Text(
                            t.observerTotalsLabel(
                              s.totalRegistered,
                              s.totalVoted,
                              s.suspiciousFlags,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CamSectionHeader(
                        title: t.observerToolsTitle,
                        icon: Icons.widgets_outlined,
                      ),
                      const SizedBox(height: 6),
                      _ToolCard(
                        icon: Icons.query_stats_outlined,
                        title: t.publicResultsTitle,
                        subtitle: t.observerResultsToolSubtitle,
                        onTap: () => context.go(RoutePaths.publicResults),
                      ),
                      _ToolCard(
                        icon: Icons.shield_outlined,
                        title: t.auditLogsTitle,
                        subtitle: t.observerOpenAuditLogs,
                        onTap: () => context.go(RoutePaths.observerAudit),
                      ),
                      _ToolCard(
                        icon: Icons.report_gmailerrorred_outlined,
                        title: t.observerReportIncidentTitle,
                        subtitle: t.observerReportIncidentSubtitle,
                        onTap: () =>
                            context.go(RoutePaths.observerIncidentReport),
                      ),
                      _ToolCard(
                        icon: Icons.manage_search_outlined,
                        title: t.observerIncidentTrackerTitle,
                        subtitle: t.observerIncidentTrackerSubtitle,
                        onTap: () =>
                            context.go(RoutePaths.observerIncidentTracker),
                      ),
                      _ToolCard(
                        icon: Icons.public_outlined,
                        title: t.observerTransparencyTitle,
                        subtitle: t.observerTransparencySubtitle,
                        onTap: () =>
                            context.go(RoutePaths.observerTransparency),
                      ),
                      _ToolCard(
                        icon: Icons.checklist_outlined,
                        title: t.observerChecklistTitle,
                        subtitle: t.observerChecklistSubtitle,
                        onTap: () => context.go(RoutePaths.observerChecklist),
                      ),
                      _ToolCard(
                        icon: Icons.map_outlined,
                        title: t.votingCentersTitle,
                        subtitle: t.votingCentersPublicSubtitle,
                        onTap: () => context.go(RoutePaths.publicVotingCenters),
                      ),
                      _ToolCard(
                        icon: Icons.menu_book_outlined,
                        title: t.legalHubTitle,
                        subtitle: t.legalHubSubtitle,
                        onTap: () => context.go(RoutePaths.legalLibrary),
                      ),
                      const SizedBox(height: 12),
                      CamReveal(
                        child: _FraudSnapshot(
                          suspiciousFlags: s.suspiciousFlags,
                          totalRegistered: s.totalRegistered,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CamSectionHeader(
                        title: t.liveResultsPreview,
                        icon: Icons.query_stats_outlined,
                      ),
                      const SizedBox(height: 6),
                      ResultsCharts(
                        candidates: chartCandidates,
                        turnoutTrend: data?.turnoutTrend,
                        watermarkTitle: t.appName,
                        watermarkSubtitle: t.observerPreviewLabel,
                      ),
                      const SizedBox(height: 12),
                      ResultsRegionMapCard(
                        winners: data?.regionalWinners ?? const [],
                        labelsByRegionCode: labelsByCode,
                        title: t.mapTitle,
                        subtitle:
                            data?.electionTitle ?? t.noElectionDataAvailable,
                        nationalWinnerName: chartCandidates.isEmpty
                            ? null
                            : (chartCandidates..sort(
                                    (a, b) => b.votes.compareTo(a.votes),
                                  ))
                                  .first
                                  .name,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        error: (e, _) => Center(child: Text(safeErrorMessage(context, e))),
        loading: () => const Center(child: CamElectionLoader()),
      ),
    );
  }

  Color _colorForCandidate(String name) {
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
}

class _FraudSnapshot extends StatelessWidget {
  final int suspiciousFlags;
  final int totalRegistered;

  const _FraudSnapshot({
    required this.suspiciousFlags,
    required this.totalRegistered,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rate = totalRegistered == 0
        ? 0
        : (suspiciousFlags / totalRegistered) * 100;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shield_outlined),
        title: Text(t.fraudIntelligenceTitle),
        subtitle: Text(
          t.fraudFlagsRateLabel(suspiciousFlags, rate.toStringAsFixed(2)),
        ),
        trailing: const Icon(Icons.auto_awesome),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
