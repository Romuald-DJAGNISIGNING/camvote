import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.role});

  final AppRole role;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;
    final error =
        authAsync.asData?.value.errorMessage ?? authAsync.error?.toString();
    final biometricEnabled = ref.watch(biometricLoginEnabledProvider);
    final biometricProfile = ref.watch(biometricLoginProfileProvider);

    final roleLabel = switch (widget.role) {
      AppRole.voter => t.modeVoterTitle,
      AppRole.observer => t.modeObserverTitle,
      AppRole.admin => t.modeAdminTitle,
      _ => t.userLabel,
    };

    return Scaffold(
      appBar: AppBar(title: Text(t.loginTitle(roleLabel))),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 8),
                  _RoleHero(roleLabel: roleLabel, role: widget.role),
                  const SizedBox(height: 12),
                  BrandHeader(
                    title: t.loginHeaderTitle(roleLabel),
                    subtitle: t.loginHeaderSubtitle,
                  ),
                  const SizedBox(height: 16),
                  _SecurityStrip(role: widget.role),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _idCtrl,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                decoration: InputDecoration(
                                  labelText: t.loginIdentifierLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? t.requiredField
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _pwCtrl,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: t.loginPasswordLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().length < 6)
                                        ? t.passwordMinLength(6)
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate()) return;
                                        await ref
                                            .read(authControllerProvider.notifier)
                                            .login(
                                              identifier: _idCtrl.text,
                                              password: _pwCtrl.text,
                                              role: widget.role,
                                            );

                                        final s = ref
                                            .read(authControllerProvider)
                                            .asData
                                            ?.value;
                                        if (s == null || !s.isAuthenticated) return;
                                        if (!context.mounted) return;
                                        context.go(_destinationForRole(s.user!.role));
                                      },
                                child: Text(isLoading ? t.signingIn : t.signIn),
                              ),
                              if (error != null && error.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  error,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => context.push(RoutePaths.authForgot),
                                child: Text(t.forgotPassword),
                              ),
                              const Divider(height: 24),
                              biometricEnabled.when(
                                data: (enabled) {
                                  if (!enabled) return const SizedBox.shrink();
                                  final label = biometricProfile.maybeWhen(
                                    data: (p) =>
                                        p == null || p.displayName.isEmpty
                                            ? t.biometricLogin
                                            : t.continueAs(p.displayName),
                                    orElse: () => t.biometricLogin,
                                  );
                                  return FilledButton.tonalIcon(
                                    onPressed:
                                        isLoading ? null : _handleBiometricLogin,
                                    icon: const Icon(Icons.fingerprint),
                                    label: Text(label),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.role == AppRole.voter)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.app_registration_outlined),
                        title: Text(t.newVoterRegistrationTitle),
                        subtitle: Text(t.newVoterRegistrationSubtitle),
                        onTap: () => context.push(RoutePaths.register),
                      ),
                    ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.support_agent_outlined),
                      title: Text(t.helpSupportTitle),
                      subtitle: Text(t.helpSupportLoginSubtitle),
                      onTap: () => context.push(RoutePaths.helpSupport),
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

  String _destinationForRole(AppRole role) {
    return switch (role) {
      AppRole.voter => RoutePaths.voterShell,
      AppRole.observer => RoutePaths.observerDashboard,
      AppRole.admin => RoutePaths.adminDashboard,
      _ => RoutePaths.publicHome,
    };
  }

  Future<void> _handleBiometricLogin() async {
    final t = AppLocalizations.of(context);
    if (kIsWeb) {
      _toast(t.biometricWebNotice);
      return;
    }

    final gate = BiometricGate();
    final supported = await gate.isSupported();
    if (!supported) {
      _toast(t.biometricNotAvailable);
      return;
    }

    final ok = await gate.requireBiometric(
      reason: t.biometricReasonSignIn,
    );
    if (!ok) return;

    if (!mounted) return;
    final live = await LivenessChallengeScreen.run(context);
    if (!live) return;

    await ref.read(authControllerProvider.notifier).biometricLogin();

    final s = ref.read(authControllerProvider).asData?.value;
    if (s == null || !s.isAuthenticated || !mounted) return;
    context.go(_destinationForRole(s.user!.role));
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _RoleHero extends StatelessWidget {
  const _RoleHero({required this.roleLabel, required this.role});

  final String roleLabel;
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    final icon = switch (role) {
      AppRole.admin => Icons.admin_panel_settings_outlined,
      AppRole.observer => Icons.visibility_outlined,
      AppRole.voter => Icons.how_to_vote_outlined,
      _ => Icons.verified_user_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BrandPalette.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: BrandPalette.softShadow,
      ),
      child: Row(
        children: [
          const CamVoteLogo(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.rolePortalTitle(roleLabel),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.rolePortalSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: BrandPalette.ink),
          ),
        ],
      ),
    );
  }
}

class _SecurityStrip extends StatelessWidget {
  const _SecurityStrip({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context);

    final chips = <String>[
      t.securityChipBiometric,
      t.securityChipLiveness,
      role == AppRole.admin ? t.securityChipAuditReady : t.securityChipFraudShield,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((label) {
        return Chip(
          label: Text(label),
          backgroundColor: cs.surfaceContainerHighest.withAlpha(180),
        );
      }).toList(),
    );
  }
}
