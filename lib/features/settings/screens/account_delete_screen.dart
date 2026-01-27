import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../shared/biometrics/biometric_gate.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';

class AccountDeleteScreen extends ConsumerStatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  ConsumerState<AccountDeleteScreen> createState() =>
      _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends ConsumerState<AccountDeleteScreen> {
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final authAsync = ref.watch(authControllerProvider);
    final isLoading = authAsync.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(t.deleteAccount)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.deleteAccount,
                subtitle: t.deleteAccountHeaderSubtitle,
              ),
              const SizedBox(height: 12),
              Text(t.deleteAccountBody),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                decoration: InputDecoration(
                  labelText: t.deleteAccountConfirmLabel(t.deleteKeyword),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_confirmCtrl.text.trim() != t.deleteKeyword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.deleteAccountConfirmError)),
                          );
                          return;
                        }

                        final bio = BiometricGate();
                        final ok = await bio.requireBiometric(
                          reason: t.deleteAccountBiometricReason,
                        );
                        if (!ok) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.biometricVerificationFailed)),
                          );
                          return;
                        }

                        await ref
                            .read(authControllerProvider.notifier)
                            .deleteAccount();
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                child: Text(
                  isLoading ? t.deletingAccount : t.deleteAccount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
