import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';

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
                  BrandHeader(
                    title: adminHomeMode
                        ? t.modeAdminTitle
                        : t.publicPortalTitle,
                    subtitle: adminHomeMode
                        ? t.modeAdminSubtitle
                        : t.publicPortalHeadline,
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
