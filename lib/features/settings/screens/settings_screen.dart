import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_settings_controller.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/theme/app_theme_style.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricBusy = false;
  bool? _biometricOverride;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.settings)),
      body: settingsAsync.when(
        loading: () => const Center(child: CamElectionLoader()),
        error: (e, _) => Center(child: Text(safeErrorMessage(context, e))),
        data: (settings) {
          final authAsync = ref.watch(authControllerProvider);
          final auth = authAsync.asData?.value;
          final biometricEnabled = ref.watch(biometricLoginEnabledProvider);
          final settingsEntry = GoRouterState.of(
            context,
          ).uri.queryParameters['entry'];
          final fromAdminPortal = settingsEntry == 'admin';
          final webSignInRole = fromAdminPortal ? 'admin' : 'observer';
          final webSignInTarget =
              '${RoutePaths.authLogin}?role=$webSignInRole&entry=${fromAdminPortal ? 'admin' : 'general'}';
          final webSignInSubtitle = fromAdminPortal
              ? t.modeAdminSubtitle
              : t.modeObserverSubtitle;

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
                              if (kIsWeb) ...[
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.login),
                                    title: Text(t.signIn),
                                    subtitle: Text(webSignInSubtitle),
                                    onTap: () => context.push(webSignInTarget),
                                  ),
                                ),
                              ] else
                                Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.login),
                                    title: Text(t.signIn),
                                    subtitle: Text(t.signInSubtitle),
                                    onTap: () => context.push(
                                      '${RoutePaths.authLogin}?role=voter',
                                    ),
                                  ),
                                )
                            else ...[
                              Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.verified_user_outlined,
                                  ),
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
                                  onTap: () async {
                                    final wasAdmin =
                                        auth.user?.role == AppRole.admin;
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .logout();
                                    if (!context.mounted) return;
                                    if (kIsWeb) {
                                      context.go(
                                        (fromAdminPortal || wasAdmin)
                                            ? RoutePaths.adminPortal
                                            : RoutePaths.webPortal,
                                      );
                                    }
                                  },
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
                              if (auth == null || !auth.isAuthenticated) {
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.lock_outline),
                                    title: Text(t.biometricLoginTitle),
                                    subtitle: Text(
                                      t.biometricEnableRequiresLogin,
                                    ),
                                    trailing: const Icon(Icons.login),
                                    onTap: () => context.push(
                                      '${RoutePaths.authLogin}?role=voter',
                                    ),
                                  ),
                                );
                              }

                              final currentValue =
                                  _biometricOverride ?? enabled;
                              return FutureBuilder<bool>(
                                future: BiometricGate().hasEnrolledBiometrics(),
                                builder: (context, snapshot) {
                                  final hasEnrolled = snapshot.data ?? false;
                                  final actionLabel = hasEnrolled
                                      ? t.reverifyBiometrics
                                      : t.enrollNow;
                                  return Card(
                                    child: SwitchListTile(
                                      title: Text(t.biometricLoginTitle),
                                      subtitle: Text(
                                        _biometricBusy
                                            ? t.loading
                                            : t.biometricLoginSubtitle,
                                      ),
                                      value: currentValue,
                                      onChanged: _biometricBusy
                                          ? null
                                          : (v) => _toggleBiometric(
                                              context,
                                              t,
                                              enabled: v,
                                            ),
                                      secondary: TextButton(
                                        onPressed: _biometricBusy
                                            ? null
                                            : () => _toggleBiometric(
                                                context,
                                                t,
                                                enabled: true,
                                              ),
                                        child: Text(actionLabel),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CamElectionLoader(
                                  size: 28,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
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
      AppThemeStyle.magic => t.themeStyleMagic,
      AppThemeStyle.fun => t.themeStyleFun,
    };
  }

  Future<void> _toggleBiometric(
    BuildContext context,
    AppLocalizations t, {
    required bool enabled,
  }) async {
    bool? resolvedValue;
    final previousValue =
        _biometricOverride ??
        ref.read(biometricLoginEnabledProvider).asData?.value ??
        false;
    setState(() {
      _biometricBusy = true;
      _biometricOverride = enabled;
    });

    try {
      if (enabled) {
        final gate = BiometricGate();
        final enrolled = await gate.hasEnrolledBiometrics();
        final supported = await gate.isSupported();
        if (!context.mounted) return;
        if (!supported) {
          _toast(
            context,
            enrolled ? t.biometricNotAvailable : t.biometricEnrollRequired,
          );
          resolvedValue = previousValue;
          return;
        }
        final ok = await gate.requireBiometric(reason: t.biometricReasonEnable);
        if (!context.mounted) return;
        if (!ok) {
          _toast(context, t.biometricVerificationFailed);
          resolvedValue = previousValue;
          return;
        }
        final live = await LivenessChallengeScreen.run(context);
        if (!context.mounted) return;
        if (!live) {
          _toast(context, t.livenessCheckFailed);
          resolvedValue = previousValue;
          return;
        }
        await ref.read(authControllerProvider.notifier).enableBiometricLogin();
      } else {
        await ref.read(authControllerProvider.notifier).disableBiometricLogin();
      }
      ref.invalidate(biometricLoginEnabledProvider);
      resolvedValue = await ref
          .read(biometricLoginEnabledProvider.future)
          .then((value) => value, onError: (_) => enabled);
      ref.invalidate(biometricLoginProfileProvider);
    } finally {
      if (mounted) {
        setState(() {
          _biometricBusy = false;
          _biometricOverride = resolvedValue ?? previousValue;
        });
      }
    }
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
