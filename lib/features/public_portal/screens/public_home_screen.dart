import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/loaders/camvote_pulse_loading.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/public_models.dart';
import '../providers/public_portal_providers.dart';

class PublicHomeScreen extends ConsumerWidget {
  const PublicHomeScreen({super.key, this.adminHomeMode = false});

  final bool adminHomeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).asData?.value;
    final entry = GoRouterState.of(context).uri.queryParameters['entry'];
    final fromAdminEntry = entry == 'admin';
    final adminContext = adminHomeMode || fromAdminEntry;
    final isAdmin =
        auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;
    final statsAsync = ref.watch(publicElectoralStatsProvider);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(adminHomeMode ? t.modeAdminTitle : t.publicPortalTitle),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: t.modeAdminTitle,
              onPressed: () {
                ref.read(currentRoleProvider.notifier).setRole(AppRole.admin);
                context.go(RoutePaths.adminDashboard);
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          IconButton(
            tooltip: t.settings,
            onPressed: () => context.push(
              '${RoutePaths.settings}?entry=${adminContext ? 'admin' : 'general'}',
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  _PublicElectoralQuickStrip(
                    stats: statsAsync,
                    onRetry: () => ref.invalidate(publicElectoralStatsProvider),
                  ),
                  const SizedBox(height: 10),
                  BrandHeader(
                    title: adminHomeMode
                        ? t.modeAdminTitle
                        : t.publicPortalTitle,
                    subtitle: adminHomeMode
                        ? t.modeAdminSubtitle
                        : t.publicPortalHeadline,
                  ),
                  const SizedBox(height: 12),
                  _PublicElectoralStatsPanel(
                    stats: statsAsync,
                    onRetry: () => ref.invalidate(publicElectoralStatsProvider),
                  ),
                  const SizedBox(height: 12),
                  if (adminHomeMode || isAdmin)
                    _ActionTile(
                      title: isAdmin ? t.adminDashboard : t.modeAdminTitle,
                      subtitle: isAdmin
                          ? t.adminDashboardHeaderSubtitle
                          : t.signIn,
                      icon: isAdmin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.lock_outline,
                      onTap: () {
                        if (!isAdmin) {
                          context.go(
                            '${RoutePaths.authLogin}?role=admin&entry=admin',
                          );
                          return;
                        }
                        ref
                            .read(currentRoleProvider.notifier)
                            .setRole(AppRole.admin);
                        context.go(RoutePaths.adminDashboard);
                      },
                    ),
                  _ActionTile(
                    title: t.publicResultsTitle,
                    subtitle: t.publicResultsSub,
                    icon: Icons.query_stats_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.publicResults,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.publicElectionsInfoTitle,
                    subtitle: t.publicElectionsInfoSub,
                    icon: Icons.event_note_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.publicElectionsInfo,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.publicElectionCalendarTitle,
                    subtitle: t.publicElectionCalendarSubtitle,
                    icon: Icons.event_available_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.publicElectionCalendar,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.publicCivicEducationTitle,
                    subtitle: t.publicCivicEducationSubtitle,
                    icon: Icons.school_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.publicCivicEducation,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.legalHubTitle,
                    subtitle: t.legalHubSubtitle,
                    icon: Icons.menu_book_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.legalLibrary,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.verifyRegistrationTitle,
                    subtitle: t.verifyRegistrationSub,
                    icon: Icons.verified_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.publicVerifyRegistration,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.votingCentersTitle,
                    subtitle: t.votingCentersPublicSubtitle,
                    icon: Icons.map_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.publicVotingCenters,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.about,
                    subtitle: t.aboutSub,
                    icon: Icons.info_outline,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.about,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.helpSupportTitle,
                    subtitle: t.helpSupportPublicSubtitle,
                    icon: Icons.support_agent_outlined,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.helpSupport,
                        entry: adminContext ? 'admin' : null,
                      ),
                    ),
                  ),
                  _ActionTile(
                    title: t.supportCamVoteTitle,
                    subtitle: t.supportCamVoteSubtitle,
                    icon: Icons.favorite_outline,
                    onTap: () => context.push(
                      _routeWithEntry(
                        RoutePaths.supportTip,
                        entry: adminContext ? 'admin' : null,
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
}

String _routeWithEntry(String path, {String? entry}) {
  if (entry == null || entry.isEmpty) return path;
  final separator = path.contains('?') ? '&' : '?';
  return '$path${separator}entry=$entry';
}

class _PublicElectoralStatsPanel extends StatelessWidget {
  const _PublicElectoralStatsPanel({
    required this.stats,
    required this.onRetry,
  });

  final AsyncValue<PublicElectoralStats> stats;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: stats.when(
          loading: () => CamVotePulseLoading(title: t.loading, compact: true),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                safeErrorMessage(context, error),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(t.retry),
              ),
            ],
          ),
          data: (value) {
            final hasData =
                value.totalRegistered > 0 ||
                value.totalVoted > 0 ||
                value.totalDeceased > 0 ||
                value.bands.any((band) => band.count > 0);
            if (!hasData) {
              return Text(t.noData, style: textTheme.bodyMedium);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.adminDemographicsTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.adminDemographicsTotalEligible(value.totalRegistered),
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatsPill(
                      icon: Icons.people_alt_outlined,
                      label: t.totalRegistered,
                      value: _formatCount(value.totalRegistered),
                    ),
                    _StatsPill(
                      icon: Icons.how_to_vote_outlined,
                      label: t.totalVotesCast,
                      value: _formatCount(value.totalVoted),
                    ),
                    _StatsPill(
                      icon: Icons.remove_circle_outline,
                      label: t.statusDeceased,
                      value: _formatCount(value.totalDeceased),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatsPill(
                      icon: Icons.bolt_outlined,
                      label: t.adminDemographicsYouth,
                      value:
                          '${_formatCount(value.youth.count)} (${value.youth.percent.toStringAsFixed(1)}%)',
                    ),
                    _StatsPill(
                      icon: Icons.groups_outlined,
                      label: t.adminDemographicsAdult,
                      value:
                          '${_formatCount(value.adult.count)} (${value.adult.percent.toStringAsFixed(1)}%)',
                    ),
                    _StatsPill(
                      icon: Icons.person_outline,
                      label: t.adminDemographicsSenior,
                      value:
                          '${_formatCount(value.senior.count)} (${value.senior.percent.toStringAsFixed(1)}%)',
                    ),
                  ],
                ),
                if (value.bands.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...value.bands.map((band) {
                    final progress = (band.percent / 100).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(band.label)),
                              Text(
                                '${_formatCount(band.count)} (${band.percent.toStringAsFixed(1)}%)',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatCount(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i += 1) {
      final indexFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

class _PublicElectoralQuickStrip extends StatelessWidget {
  const _PublicElectoralQuickStrip({
    required this.stats,
    required this.onRetry,
  });

  final AsyncValue<PublicElectoralStats> stats;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: stats.when(
          loading: () => Row(
            children: [
              const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(t.loading, style: textTheme.bodySmall),
            ],
          ),
          error: (_, _) => Row(
            children: [
              Expanded(child: Text(t.noData, style: textTheme.bodySmall)),
              TextButton(onPressed: onRetry, child: Text(t.retry)),
            ],
          ),
          data: (value) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatsPill(
                icon: Icons.people_alt_outlined,
                label: t.totalRegistered,
                value: _formatCount(value.totalRegistered),
              ),
              _StatsPill(
                icon: Icons.remove_circle_outline,
                label: t.statusDeceased,
                value: _formatCount(value.totalDeceased),
              ),
              _StatsPill(
                icon: Icons.bolt_outlined,
                label: t.adminDemographicsYouth,
                value: '${value.youth.percent.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i += 1) {
      final indexFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}

class _StatsPill extends StatelessWidget {
  const _StatsPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(110)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.primary),
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
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
