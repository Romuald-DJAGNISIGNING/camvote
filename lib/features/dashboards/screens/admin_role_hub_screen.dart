import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class AdminRoleHubScreen extends ConsumerWidget {
  const AdminRoleHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider).asData?.value;
    final userRole = authState?.user?.role;
    final isAdminAuthed =
        authState?.isAuthenticated == true && userRole == AppRole.admin;
    final roleCtrl = ref.read(currentRoleProvider.notifier);

    return Scaffold(
      appBar: NotificationAppBar(
        showBack: false,
        title: Row(
          children: [
            const CamVoteLogo(size: 28),
            const SizedBox(width: 10),
            Text(t.modeAdminTitle),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.settings,
            onPressed: () => context.push('${RoutePaths.settings}?entry=admin'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: SingleChildScrollView(
            child: CamStagger(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                BrandHeader(
                  title: t.modeAdminTitle,
                  subtitle: isAdminAuthed
                      ? t.adminDashboardHeaderSubtitle
                      : t.publicPortalHeadline,
                ),
                const SizedBox(height: 14),
                _ActionTile(
                  title: isAdminAuthed ? t.adminDashboard : t.modeAdminTitle,
                  subtitle: isAdminAuthed
                      ? t.adminDashboardHeaderSubtitle
                      : t.modeAdminSubtitle,
                  icon: isAdminAuthed
                      ? Icons.admin_panel_settings_outlined
                      : Icons.lock_outline,
                  onTap: () {
                    if (isAdminAuthed) {
                      roleCtrl.setRole(AppRole.admin);
                      context.go(RoutePaths.adminDashboard);
                      return;
                    }
                    context.go(
                      '${RoutePaths.authLogin}?role=admin&entry=admin',
                    );
                  },
                ),
                if (isAdminAuthed) ...[
                  const SizedBox(height: 10),
                  _ActionTile(
                    title: t.signOut,
                    subtitle: t.modeAdminSubtitle,
                    icon: Icons.logout,
                    onTap: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go(RoutePaths.adminPortal);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                _ActionTile(
                  title: t.publicResultsTitle,
                  subtitle: t.publicResultsSub,
                  icon: Icons.query_stats_outlined,
                  onTap: () => context.push(
                    _routeWithEntry(RoutePaths.publicResults, entry: 'admin'),
                  ),
                ),
                _ActionTile(
                  title: t.publicElectionsInfoTitle,
                  subtitle: t.publicElectionsInfoSub,
                  icon: Icons.event_note_outlined,
                  onTap: () => context.push(
                    _routeWithEntry(
                      RoutePaths.publicElectionsInfo,
                      entry: 'admin',
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
                      entry: 'admin',
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
                      entry: 'admin',
                    ),
                  ),
                ),
                _ActionTile(
                  title: t.legalHubTitle,
                  subtitle: t.legalHubSubtitle,
                  icon: Icons.menu_book_outlined,
                  onTap: () => context.push(
                    _routeWithEntry(RoutePaths.legalLibrary, entry: 'admin'),
                  ),
                ),
                _ActionTile(
                  title: t.verifyRegistrationTitle,
                  subtitle: t.verifyRegistrationSub,
                  icon: Icons.verified_outlined,
                  onTap: () => context.push(
                    _routeWithEntry(
                      RoutePaths.publicVerifyRegistration,
                      entry: 'admin',
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
                      entry: 'admin',
                    ),
                  ),
                ),
                _ActionTile(
                  title: t.about,
                  subtitle: t.aboutSub,
                  icon: Icons.info_outline,
                  onTap: () => context.push(
                    _routeWithEntry(RoutePaths.about, entry: 'admin'),
                  ),
                ),
                _ActionTile(
                  title: t.helpSupportTitle,
                  subtitle: t.helpSupportPublicSubtitle,
                  icon: Icons.support_agent_outlined,
                  onTap: () => context.push(
                    _routeWithEntry(RoutePaths.helpSupport, entry: 'admin'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

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

String _routeWithEntry(String path, {required String entry}) {
  final separator = path.contains('?') ? '&' : '?';
  return '$path${separator}entry=$entry';
}
