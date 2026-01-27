import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_settings_controller.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/theme/app_theme_style.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.settings)),
      body: settingsAsync.when(
        loading: () => const Center(child: CamElectionLoader()),
        error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
        data: (settings) {
          final authAsync = ref.watch(authControllerProvider);
          final auth = authAsync.asData?.value;
          final biometricEnabled = ref.watch(biometricLoginEnabledProvider);

          void toast(String message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }

          return BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.settings,
                        subtitle: t.settingsSubtitle,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: t.appearance,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text(t.system),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text(t.light),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text(t.dark),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (set) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .setThemeMode(set.first);
                          },
                        ),
                      ),
                      _SectionCard(
                        title: t.themeStyleTitle,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AppThemeStyle.values.map((style) {
                            final selected = settings.themeStyle == style;
                            return ChoiceChip(
                              label: Text(_styleLabel(t, style)),
                              selected: selected,
                              onSelected: (_) => ref
                                  .read(appSettingsProvider.notifier)
                                  .setThemeStyle(style),
                            );
                          }).toList(),
                        ),
                      ),
                      _SectionCard(
                        title: t.language,
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'en',
                              label: Text(t.languageEnglish),
                            ),
                            ButtonSegment(
                              value: 'fr',
                              label: Text(t.languageFrench),
                            ),
                          ],
                          selected: {settings.locale.languageCode},
                          onSelectionChanged: (set) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .setLocale(Locale(set.first));
                          },
                        ),
                      ),
                      _SectionCard(
                        title: t.accountSectionTitle,
                        child: Column(
                          children: [
                            if (auth == null || !auth.isAuthenticated)
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.login),
                                  title: Text(t.signIn),
                                  subtitle: Text(t.signInSubtitle),
                                  onTap: () => context
                                      .push('${RoutePaths.authLogin}?role=voter'),
                                ),
                              )
                            else ...[
                              Card(
                                child: ListTile(
                                  leading:
                                      const Icon(Icons.verified_user_outlined),
                                  title: Text(
                                    auth.user?.fullName ?? t.signedInUser,
                                  ),
                                  subtitle: Text(auth.user?.email ?? ''),
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.logout),
                                  title: Text(t.signOut),
                                  onTap: () => ref
                                      .read(authControllerProvider.notifier)
                                      .logout(),
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.delete_outline),
                                  title: Text(t.deleteAccount),
                                  subtitle: Text(t.deleteAccountSubtitle),
                                  onTap: () =>
                                      context.push(RoutePaths.accountDelete),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!kIsWeb)
                        _SectionCard(
                          title: t.securitySectionTitle,
                          child: biometricEnabled.when(
                            data: (enabled) {
                              return Card(
                                child: SwitchListTile(
                                  title: Text(t.biometricLoginTitle),
                                  subtitle: Text(t.biometricLoginSubtitle),
                                  value: enabled,
                                  onChanged: (v) async {
                                    if (v) {
                                      final gate = BiometricGate();
                                      final supported = await gate.isSupported();
                                      if (!context.mounted) return;
                                      if (!supported) {
                                        toast(
                                          t.biometricNotAvailable,
                                        );
                                        return;
                                      }
                                      final ok = await gate.requireBiometric(
                                        reason: t.biometricReasonEnable,
                                      );
                                      if (!context.mounted) return;
                                      if (!ok) return;
                                      if (!context.mounted) return;
                                      final live =
                                          await LivenessChallengeScreen.run(
                                        context,
                                      );
                                      if (!context.mounted) return;
                                      if (!live) return;
                                      await ref
                                          .read(authControllerProvider.notifier)
                                          .enableBiometricLogin();
                                    } else {
                                      await ref
                                          .read(authControllerProvider.notifier)
                                          .disableBiometricLogin();
                                    }
                                    ref.invalidate(
                                      biometricLoginEnabledProvider,
                                    );
                                    ref.invalidate(
                                      biometricLoginProfileProvider,
                                    );
                                  },
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      _SectionCard(
                        title: t.supportSectionTitle,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.support_agent_outlined),
                            title: Text(t.helpSupportTitle),
                            subtitle: Text(t.helpSupportSettingsSubtitle),
                            onTap: () => context.push(RoutePaths.helpSupport),
                          ),
                        ),
                      ),
                      _SectionCard(
                        title: t.onboardingSectionTitle,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.auto_awesome),
                            title: Text(t.onboardingReplayTitle),
                            subtitle: Text(t.onboardingReplaySubtitle),
                            onTap: () => context.push(RoutePaths.onboarding),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _styleLabel(AppLocalizations t, AppThemeStyle style) {
    return switch (style) {
      AppThemeStyle.classic => t.themeStyleClassic,
      AppThemeStyle.cameroon => t.themeStyleCameroon,
      AppThemeStyle.geek => t.themeStyleGeek,
      AppThemeStyle.fruity => t.themeStyleFruity,
      AppThemeStyle.pro => t.themeStylePro,
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
