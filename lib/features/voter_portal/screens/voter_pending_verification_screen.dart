import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class VoterPendingVerificationScreen extends ConsumerWidget {
  const VoterPendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.verificationPendingTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.verificationPendingTitle,
                    subtitle: t.verificationPendingSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(auth?.user?.fullName ?? t.signedInVoter),
                      subtitle: Text(auth?.user?.email ?? ''),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HeroStatusCard(
                    title: t.verificationPendingTitle,
                    subtitle: t.verificationPendingBody,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.verificationTimelineTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          _TimelineStep(
                            icon: Icons.assignment_turned_in_outlined,
                            title: t.verificationStepSubmittedTitle,
                            body: t.verificationStepSubmittedBody,
                            active: true,
                          ),
                          const SizedBox(height: 10),
                          _TimelineStep(
                            icon: Icons.pending_actions_outlined,
                            title: t.verificationStepReviewTitle,
                            body: t.verificationStepReviewBody,
                            active: true,
                          ),
                          const SizedBox(height: 10),
                          _TimelineStep(
                            icon: Icons.notifications_active_outlined,
                            title: t.verificationStepDecisionTitle,
                            body: t.verificationStepDecisionBody,
                            active: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        context.go(RoutePaths.publicVerifyRegistration),
                    icon: const Icon(Icons.search),
                    label: Text(t.verificationPendingPrimaryAction),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(currentRoleProvider.notifier)
                          .setRole(AppRole.public);
                      context.go(RoutePaths.publicHome);
                    },
                    icon: const Icon(Icons.public),
                    label: Text(t.verificationPendingSecondaryAction),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => context.push(RoutePaths.helpSupport),
                    icon: const Icon(Icons.support_agent_outlined),
                    label: Text(t.verificationPendingSupportAction),
                  ),
                  const SizedBox(height: 6),
                  if (auth?.isAuthenticated == true)
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (!context.mounted) return;
                        ref
                            .read(currentRoleProvider.notifier)
                            .setRole(AppRole.public);
                        context.go(RoutePaths.publicHome);
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(t.verificationPendingSignOut),
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

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [cs.primary.withAlpha(210), cs.secondary.withAlpha(190)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withAlpha(30),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withAlpha(220),
                    ),
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

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.active,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = active ? cs.primary : cs.outline;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(120)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withAlpha(170),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
