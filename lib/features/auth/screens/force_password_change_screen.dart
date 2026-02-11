import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../models/auth_error_codes.dart';
import '../providers/auth_providers.dart';
import '../utils/auth_error_utils.dart';

class ForcePasswordChangeScreen extends ConsumerStatefulWidget {
  const ForcePasswordChangeScreen({super.key});

  @override
  ConsumerState<ForcePasswordChangeScreen> createState() =>
      _ForcePasswordChangeScreenState();
}

class _ForcePasswordChangeScreenState
    extends ConsumerState<ForcePasswordChangeScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final authAsync = ref.watch(authControllerProvider);
    final loading = authAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(t.authMustChangePassword)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 12),
              BrandHeader(
                title: t.authMustChangePassword,
                subtitle: t.authMustChangePasswordHelp,
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: t.passwordLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 8) {
                              return t.passwordMinLength(8);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: t.passwordConfirmLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return t.passwordMismatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: loading ? null : _submitPasswordChange,
                            child: Text(t.authUpdatePasswordAction),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPasswordChange() async {
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authControllerProvider.notifier)
        .completeFirstLoginPasswordChange(_passwordController.text.trim());

    if (!mounted) return;
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState?.isAuthenticated == true && authState?.user != null) {
      final destination = switch (authState!.user!.role) {
        AppRole.voter => kIsWeb ? RoutePaths.webPortal : RoutePaths.voterShell,
        AppRole.observer => RoutePaths.observerDashboard,
        AppRole.admin => RoutePaths.adminDashboard,
        _ => RoutePaths.publicHome,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.authPasswordUpdated)));
      context.go(destination);
      return;
    }

    final code = authState?.errorCode ?? AuthErrorCodes.unknown;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(authErrorMessageFromCode(t, code))));
  }
}
