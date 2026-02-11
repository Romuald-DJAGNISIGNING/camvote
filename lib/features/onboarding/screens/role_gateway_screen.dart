import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/marketing/app_download_card.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class RoleGatewayScreen extends ConsumerWidget {
  const RoleGatewayScreen({
    super.key,
    this.isGeneralWebPortal = false,
    this.adminOnly = false,
  });

  final bool isGeneralWebPortal;
  final bool adminOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider).asData?.value;

    final isWeb = kIsWeb;
    final generalWebPortal = isWeb && isGeneralWebPortal && !adminOnly;
    final adminOnlyMode = adminOnly;
    final isAdminAuthed =
        auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;
    final webHint = adminOnlyMode
        ? t.modeAdminTitle
        : '${t.modePublicTitle} - ${t.modeObserverTitle}';
    final screen = Scaffold(
      appBar: NotificationAppBar(
        showBack: false,
        title: Row(
          children: [
            const CamVoteLogo(size: 28),
            const SizedBox(width: 10),
            Text(t.appName),
          ],
        ),
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: SingleChildScrollView(
            child: CamStagger(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                _HeroBanner(title: t.appName, slogan: t.slogan),
                const SizedBox(height: 16),
                BrandHeader(
                  title: adminOnlyMode ? t.modeAdminTitle : t.chooseModeTitle,
                  subtitle: adminOnlyMode
                      ? t.modeAdminSubtitle
                      : t.roleGatewaySubtitle,
                ),
                const SizedBox(height: 16),
                _FeatureStrip(
                  items: [
                    _FeatureItem(
                      icon: Icons.verified_user_outlined,
                      title: t.roleGatewayFeatureVerifiedTitle,
                      subtitle: t.roleGatewayFeatureVerifiedSubtitle,
                    ),
                    _FeatureItem(
                      icon: Icons.shield_outlined,
                      title: t.roleGatewayFeatureFraudTitle,
                      subtitle: t.roleGatewayFeatureFraudSubtitle,
                    ),
                    _FeatureItem(
                      icon: Icons.public,
                      title: t.roleGatewayFeatureTransparencyTitle,
                      subtitle: t.roleGatewayFeatureTransparencySubtitle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (adminOnlyMode)
                  _RoleCard(
                    title: t.modeAdminTitle,
                    subtitle: isAdminAuthed
                        ? t.adminDashboardHeaderSubtitle
                        : t.modeAdminSubtitle,
                    icon: Icons.admin_panel_settings_outlined,
                    onTap: () {
                      ref
                          .read(currentRoleProvider.notifier)
                          .setRole(AppRole.admin);
                      if (isAdminAuthed) {
                        context.go(RoutePaths.adminDashboard);
                        return;
                      }
                      context.go(
                        '${RoutePaths.authLogin}?role=admin&entry=admin',
                      );
                    },
                  )
                else ...[
                  _RoleCard(
                    title: t.modePublicTitle,
                    subtitle: t.modePublicSubtitle,
                    icon: Icons.public,
                    onTap: () {
                      ref
                          .read(currentRoleProvider.notifier)
                          .setRole(AppRole.public);
                      context.go(RoutePaths.publicHome);
                    },
                  ),
                  if (!isWeb && !generalWebPortal)
                    _RoleCard(
                      title: t.modeVoterTitle,
                      subtitle: isWeb
                          ? t.webDownloadAppSubtitle
                          : t.modeVoterSubtitle,
                      icon: Icons.how_to_vote_outlined,
                      onTap: () {
                        if (isWeb) {
                          context.go(RoutePaths.voterWebRedirect);
                        } else {
                          context.go('${RoutePaths.authLogin}?role=voter');
                        }
                      },
                    ),
                  if (generalWebPortal)
                    _RoleCard(
                      title: t.modeObserverTitle,
                      subtitle: t.modeObserverSubtitle,
                      icon: Icons.visibility_outlined,
                      onTap: () {
                        context.go('${RoutePaths.authLogin}?role=observer');
                      },
                    ),
                  if (generalWebPortal) ...[
                    const SizedBox(height: 12),
                    const AppDownloadCard(),
                  ],
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push(
                    adminOnlyMode
                        ? '${RoutePaths.settings}?entry=admin'
                        : generalWebPortal
                        ? '${RoutePaths.settings}?entry=general'
                        : RoutePaths.settings,
                  ),
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(t.settings),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(RoutePaths.about),
                  icon: const Icon(Icons.info_outline),
                  label: Text(t.about),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push(RoutePaths.helpSupport),
                  icon: const Icon(Icons.support_agent_outlined),
                  label: Text(t.helpSupportTitle),
                ),
                if (isWeb)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      adminOnlyMode ? t.modeAdminSubtitle : webHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      adminOnlyMode
                          ? t.modeAdminSubtitle
                          : t.roleGatewayMobileHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (generalWebPortal) {
      return Theme(data: _portalTheme(context, AppRole.public), child: screen);
    }
    if (adminOnlyMode) {
      return Theme(data: _portalTheme(context, AppRole.admin), child: screen);
    }

    return screen;
  }

  ThemeData _portalTheme(BuildContext context, AppRole role) {
    final base = Theme.of(context);
    final primary = RoleTheme.accentFor(role);
    final secondary = RoleTheme.secondaryFor(role);
    final scheme = base.colorScheme.copyWith(
      primary: primary,
      primaryContainer: primary.withAlpha(28),
      secondary: secondary,
      secondaryContainer: secondary.withAlpha(25),
      inversePrimary: primary.withAlpha(200),
    );
    return base.copyWith(colorScheme: scheme);
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
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
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cs.primary.withAlpha(26),
          child: Icon(icon, color: cs.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String slogan;

  const _HeroBanner({required this.title, required this.slogan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = isDark
        ? BrandPalette.darkHeroGradient
        : BrandPalette.heroGradient;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: gradient,
        boxShadow: BrandPalette.softShadow,
      ),
      child: Row(
        children: [
          const CamVoteLogo(size: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  slogan,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  final List<_FeatureItem> items;
  const _FeatureStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;
        if (isNarrow) {
          return Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _FeatureCard(item: items[i], cs: cs),
                if (i < items.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              Expanded(
                child: _FeatureCard(item: items[i], cs: cs),
              ),
              if (i < items.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  final ColorScheme cs;

  const _FeatureCard({required this.item, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(item.icon, color: cs.primary),
          const SizedBox(height: 6),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
