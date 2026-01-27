import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:camvote/gen/l10n/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../notifications/widgets/notification_app_bar.dart';


class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.publicPortalTitle),
        actions: [
          IconButton(
            tooltip: t.settings,
            onPressed: () => context.push(RoutePaths.settings),
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
                    title: t.publicPortalTitle,
                    subtitle: t.publicPortalHeadline,
                  ),
                  const SizedBox(height: 16),
                  _ActionTile(
                    title: t.publicResultsTitle,
                    subtitle: t.publicResultsSub,
                    icon: Icons.query_stats_outlined,
                    onTap: () => context.push(RoutePaths.publicResults),
                  ),
                  _ActionTile(
                    title: t.publicElectionsInfoTitle,
                    subtitle: t.publicElectionsInfoSub,
                    icon: Icons.event_note_outlined,
                    onTap: () => context.push(RoutePaths.publicElectionsInfo),
                  ),
                  _ActionTile(
                    title: t.publicElectionCalendarTitle,
                    subtitle: t.publicElectionCalendarSubtitle,
                    icon: Icons.event_available_outlined,
                    onTap: () => context.push(RoutePaths.publicElectionCalendar),
                  ),
                  _ActionTile(
                    title: t.publicCivicEducationTitle,
                    subtitle: t.publicCivicEducationSubtitle,
                    icon: Icons.school_outlined,
                    onTap: () => context.push(RoutePaths.publicCivicEducation),
                  ),
                  _ActionTile(
                    title: t.legalHubTitle,
                    subtitle: t.legalHubSubtitle,
                    icon: Icons.menu_book_outlined,
                    onTap: () => context.push(RoutePaths.legalLibrary),
                  ),
                  _ActionTile(
                    title: t.verifyRegistrationTitle,
                    subtitle: t.verifyRegistrationSub,
                    icon: Icons.verified_outlined,
                    onTap: () => context.push(RoutePaths.publicVerifyRegistration),
                  ),
                  _ActionTile(
                    title: t.votingCentersTitle,
                    subtitle: t.votingCentersPublicSubtitle,
                    icon: Icons.map_outlined,
                    onTap: () => context.push(RoutePaths.publicVotingCenters),
                  ),
                  _ActionTile(
                    title: t.about,
                    subtitle: t.aboutSub,
                    icon: Icons.info_outline,
                    onTap: () => context.push(RoutePaths.about),
                  ),
                  _ActionTile(
                    title: t.helpSupportTitle,
                    subtitle: t.helpSupportPublicSubtitle,
                    icon: Icons.support_agent_outlined,
                    onTap: () => context.push(RoutePaths.helpSupport),
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
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
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
