import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';

class VoterProfileScreen extends ConsumerWidget {
  const VoterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).asData?.value;

    return BrandBackdrop(
      child: ResponsiveContent(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CamStagger(
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.voterProfile,
                  subtitle: t.voterProfileSubtitle,
                ),
                const SizedBox(height: 12),
                _ProfileHeroCard(
                  fullName: auth?.user?.fullName ?? t.signedInVoter,
                  email: auth?.user?.email ?? '',
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: Text(t.verificationStatusTitle),
                    subtitle: Text(
                      auth?.user?.verified == true
                          ? t.verificationStatusVerified
                          : t.verificationStatusPending,
                    ),
                    trailing: auth?.user?.verified == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.pending),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(t.settings),
                    subtitle: Text(t.appearance),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: Text(t.electoralCardTitle),
                    subtitle: Text(t.electoralCardViewSubtitle),
                    onTap: () => context.push(RoutePaths.voterCard),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(t.voterCountdowns),
                    subtitle: Text(t.voterCountdownsSubtitle),
                    onTap: () => context.push(RoutePaths.voterCountdowns),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(t.deleteAccount),
                    subtitle: Text(t.deleteAccountSubtitle),
                    onTap: () => context.push(RoutePaths.accountDelete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.fullName, required this.email});

  final String fullName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [cs.primary.withAlpha(200), cs.tertiary.withAlpha(170)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withAlpha(30),
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (email.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
