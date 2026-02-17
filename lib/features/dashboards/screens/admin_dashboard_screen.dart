import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../../../core/widgets/animations/animated_counter.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../core/theme/role_theme.dart';
import '../../public_portal/widgets/results_charts.dart';
import '../../public_portal/widgets/results_region_map_card.dart';
import '../../public_portal/providers/public_portal_providers.dart';
import '../../public_portal/utils/candidate_metric.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/admin_models.dart';
import '../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final demographics = ref.watch(voterDemographicsProvider);
    final results = ref.watch(publicResultsProvider);
    final auth = ref.watch(authControllerProvider).asData?.value;
    final isAdminAuthed =
        auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.adminDashboard),
        actions: [
          if (isAdminAuthed)
            IconButton(
              tooltip: t.signOut,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (!context.mounted) return;
                context.go(
                  kIsWeb ? RoutePaths.adminPortal : RoutePaths.gateway,
                );
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

          final nationalWinnerName = chartCandidates.isEmpty
              ? null
              : (chartCandidates.toList()
                      ..sort((a, b) => b.votes.compareTo(a.votes)))
                    .first
                    .name;

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
                        title: t.adminDashboard,
                        subtitle: t.adminDashboardHeaderSubtitle,
                      ),
                      const SizedBox(height: 16),
                      _grid(
                        context,
                        children: [
                          _statCard(
                            context,
                            label: t.statRegistered,
                            value: s.totalRegistered,
                            icon: Icons.how_to_vote_outlined,
                            accent: const Color(0xFF0A7D2E),
                          ),
                          _statCard(
                            context,
                            label: t.statVoted,
                            value: s.totalVoted,
                            icon: Icons.verified_outlined,
                            accent: const Color(0xFF1C6DD0),
                          ),
                          _statCard(
                            context,
                            label: t.statActiveElections,
                            value: s.activeElections,
                            icon: Icons.event_available_outlined,
                            accent: const Color(0xFFF5B700),
                          ),
                          _statCard(
                            context,
                            label: t.statSuspiciousFlags,
                            value: s.suspiciousFlags,
                            icon: Icons.report_gmailerrorred_outlined,
                            accent: const Color(0xFFB3261E),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CamSectionHeader(
                        title: '${t.modeAdminTitle} & ${t.modeObserverTitle}',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 6),
                      _staffPanel(
                        context,
                        adminCount: s.adminCount,
                        observerCount: s.observerCount,
                        onManageObservers: () =>
                            context.go(RoutePaths.adminObservers),
                      ),
                      const SizedBox(height: 12),
                      CamSectionHeader(
                        title: t.adminToolsTitle,
                        icon: Icons.widgets_outlined,
                      ),
                      const SizedBox(height: 6),
                      _toolsGrid(
                        context,
                        actions: [
                          _action(
                            context,
                            icon: Icons.hub_outlined,
                            label: t.chooseModeTitle,
                            onTap: () => context.go(RoutePaths.adminPortal),
                          ),
                          _action(
                            context,
                            icon: Icons.public_outlined,
                            label: t.publicPortalTitle,
                            onTap: () => context.push(
                              '${RoutePaths.publicHome}?entry=admin',
                            ),
                          ),
                          _action(
                            context,
                            icon: Icons.how_to_vote,
                            label: t.adminActionElections,
                            onTap: () => context.go(RoutePaths.adminElections),
                          ),
                          _action(
                            context,
                            icon: Icons.people_alt,
                            label: t.adminActionVoters,
                            onTap: () => context.go(RoutePaths.adminVoters),
                          ),
                          _action(
                            context,
                            icon: Icons.visibility_outlined,
                            label: t.adminObserverAccessTitle,
                            onTap: () => context.go(RoutePaths.adminObservers),
                          ),
                          _action(
                            context,
                            icon: Icons.shield,
                            label: t.adminActionAuditLogs,
                            onTap: () => context.go(RoutePaths.adminAudit),
                          ),
                          _action(
                            context,
                            icon: Icons.auto_awesome_outlined,
                            label: t.adminFraudMonitorTitle,
                            onTap: () =>
                                context.go(RoutePaths.adminFraudMonitor),
                          ),
                          _action(
                            context,
                            icon: Icons.security_outlined,
                            label: t.adminSecurityTitle,
                            onTap: () => context.go(RoutePaths.adminSecurity),
                          ),
                          _action(
                            context,
                            icon: Icons.report_gmailerrorred_outlined,
                            label: t.adminIncidentsTitle,
                            onTap: () => context.go(RoutePaths.adminIncidents),
                          ),
                          _action(
                            context,
                            icon: Icons.location_on_outlined,
                            label: t.adminVotingCentersTitle,
                            onTap: () =>
                                context.go(RoutePaths.adminVotingCenters),
                          ),
                          _action(
                            context,
                            icon: Icons.storage_outlined,
                            label: t.adminContentSeedTitle,
                            onTap: () =>
                                context.go(RoutePaths.adminContentSeed),
                          ),
                          _action(
                            context,
                            icon: Icons.rocket_launch_outlined,
                            label: t.adminResultsPublishTitle,
                            onTap: () =>
                                context.go(RoutePaths.adminResultsPublish),
                          ),
                          _action(
                            context,
                            icon: Icons.support_agent_outlined,
                            label: t.helpSupportTitle,
                            onTap: () => context.go(RoutePaths.adminSupport),
                          ),
                          _action(
                            context,
                            icon: Icons.volunteer_activism_outlined,
                            label: t.supportCamVoteTitle,
                            onTap: () => context.go(RoutePaths.adminTips),
                          ),
                          _action(
                            context,
                            icon: Icons.menu_book_outlined,
                            label: t.legalHubTitle,
                            onTap: () => context.go(RoutePaths.legalLibrary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CamReveal(
                        child: _FraudInsightPanel(
                          suspiciousFlags: s.suspiciousFlags,
                          totalRegistered: s.totalRegistered,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CamSectionHeader(
                        title: t.adminDemographicsTitle,
                        icon: Icons.groups_2_outlined,
                      ),
                      const SizedBox(height: 6),
                      demographics.when(
                        data: (value) => _demographicsCard(context, value),
                        loading: () => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CamElectionLoader(size: 40, strokeWidth: 4),
                            ),
                          ),
                        ),
                        error: (e, _) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(safeErrorMessage(context, e)),
                          ),
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
                        watermarkSubtitle: t.adminPreviewLabel,
                      ),
                      const SizedBox(height: 12),
                      ResultsRegionMapCard(
                        winners: data?.regionalWinners ?? const [],
                        labelsByRegionCode: labelsByCode,
                        title: t.mapTitle,
                        subtitle:
                            data?.electionTitle ?? t.noElectionDataAvailable,
                        nationalWinnerName: nationalWinnerName,
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

  Widget _grid(BuildContext context, {required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final wide = width >= 900;
        final crossAxisCount = wide
            ? 4
            : width >= 560
            ? 2
            : 1;
        final aspect = wide
            ? 1.6
            : crossAxisCount == 2
            ? 1.4
            : 3.4;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: aspect,
          children: children,
        );
      },
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color accent,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withAlpha(70)),
          gradient: LinearGradient(
            colors: [accent.withAlpha(30), cs.surface.withAlpha(10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCounter(value: value),
          ],
        ),
      ),
    );
  }

  Widget _toolsGrid(BuildContext context, {required List<Widget> actions}) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final wide = width >= 900;
        final crossAxisCount = wide
            ? 4
            : width >= 560
            ? 2
            : 1;
        final aspect = wide
            ? 1.6
            : crossAxisCount == 2
            ? 1.4
            : 3.2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: aspect,
          children: actions,
        );
      },
    );
  }

  Widget _action(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _staffPanel(
    BuildContext context, {
    required int adminCount,
    required int observerCount,
    required VoidCallback onManageObservers,
  }) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final staffTotal = adminCount + observerCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _staffMetric(
                  context,
                  label: t.modeAdminTitle,
                  value: adminCount,
                  icon: Icons.admin_panel_settings_outlined,
                  color: cs.primary,
                ),
                _staffMetric(
                  context,
                  label: t.modeObserverTitle,
                  value: observerCount,
                  icon: Icons.visibility_outlined,
                  color: cs.secondary,
                ),
                _staffMetric(
                  context,
                  label: '${t.modeAdminTitle} + ${t.modeObserverTitle}',
                  value: staffTotal,
                  icon: Icons.groups_2_outlined,
                  color: cs.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onManageObservers,
              icon: const Icon(Icons.manage_accounts_outlined),
              label: Text(t.adminObserverManagementTitle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffMetric(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(90)),
        color: color.withAlpha(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '$value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _demographicsCard(BuildContext context, VoterDemographics value) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final youth = value.youth;
    final adult = value.adult;
    final senior = value.senior;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.adminDemographicsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              t.adminDemographicsTotalEligible(value.total),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ...value.bands.map((band) {
              final pct = band.percent.clamp(0, 100) / 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(band.label)),
                        Text('${band.count} (${band.percent.toStringAsFixed(1)}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(999),
                      color: cs.primary,
                      backgroundColor: cs.primaryContainer.withAlpha(80),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _pill(
                  context,
                  label: t.adminDemographicsYouth,
                  value:
                      '${youth.count} (${youth.percent.toStringAsFixed(1)}%)',
                ),
                _pill(
                  context,
                  label: t.adminDemographicsAdult,
                  value:
                      '${adult.count} (${adult.percent.toStringAsFixed(1)}%)',
                ),
                _pill(
                  context,
                  label: t.adminDemographicsSenior,
                  value:
                      '${senior.count} (${senior.percent.toStringAsFixed(1)}%)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, {required String label, required String value}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FraudInsightPanel extends StatelessWidget {
  final int suspiciousFlags;
  final int totalRegistered;

  const _FraudInsightPanel({
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;
                final title = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        t.fraudIntelligenceTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                );
                final badge = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    t.fraudAiStatus,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 8), badge],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: title),
                    badge,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              t.fraudSignalsFlagged(suspiciousFlags),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              t.fraudAnomalyRate(rate.toStringAsFixed(2)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const CamElectionLoader(size: 18, strokeWidth: 2.4),
                const SizedBox(width: 10),
                Text(
                  '${totalRegistered == 0 ? 0 : ((suspiciousFlags / totalRegistered) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              t.fraudInsightBody,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
