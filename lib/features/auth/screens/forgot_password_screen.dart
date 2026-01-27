import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../providers/auth_providers.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/branding/brand_logo.dart';
import '../../../core/branding/brand_palette.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/routing/route_paths.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(t.forgotPasswordTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  const _ResetHero(),
                  const SizedBox(height: 12),
                  BrandHeader(
                    title: t.forgotPasswordTitle,
                    subtitle: t.forgotPasswordSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        labelText: t.loginIdentifierLabel,
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? t.requiredField : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            await ref
                                .read(authControllerProvider.notifier)
                                .requestPasswordReset(_ctrl.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.forgotPasswordSuccess)),
                            );
                          },
                    child: Text(
                      isLoading ? t.forgotPasswordSending : t.forgotPasswordSend,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.support_agent_outlined),
                      title: Text(t.forgotPasswordNeedHelpTitle),
                      subtitle: Text(t.forgotPasswordNeedHelpSubtitle),
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
}

class _ResetHero extends StatelessWidget {
  const _ResetHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: BrandPalette.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: BrandPalette.softShadow,
      ),
      child: Row(
        children: [
          const CamVoteLogo(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.forgotPasswordHeroTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.forgotPasswordHeroSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset, color: BrandPalette.ink),
          ),
        ],
      ),
    );
  }
}
