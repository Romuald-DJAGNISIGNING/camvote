import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import '../../../core/routing/route_paths.dart';
import '../providers/auth_providers.dart';

class AccountArchivedScreen extends ConsumerWidget {
  const AccountArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(alwaysVisible: false),
        title: Text(t.accountArchivedTitle),
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
                    title: t.accountArchivedTitle,
                    subtitle: t.accountArchivedSubtitle,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t.accountArchivedBody),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).clearError();
                      context.go(
                        kIsWeb
                            ? '${RoutePaths.authLogin}?role=observer'
                            : RoutePaths.authLogin,
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: Text(t.accountArchivedLoginAction),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).clearError();
                      context.go(RoutePaths.gateway);
                    },
                    icon: const Icon(Icons.public),
                    label: Text(t.accountArchivedPublicAction),
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
