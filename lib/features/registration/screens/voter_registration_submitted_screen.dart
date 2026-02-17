import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import '../../../core/theme/role_theme.dart';
import '../models/registration_submission_result.dart';

class VoterRegistrationSubmittedScreen extends ConsumerWidget {
  final RegistrationSubmissionResult result;

  const VoterRegistrationSubmittedScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final statusLabel = _statusLabel(t, result.status);
    final queueId = result.offlineQueueId.isEmpty
        ? (result.registrationId.isEmpty ? t.unknown : result.registrationId)
        : result.offlineQueueId;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.registrationSubmittedTitle),
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.registrationSubmittedTitle,
                subtitle: t.registrationSubmittedSubtitle,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row(label: t.status, value: statusLabel),
                      _Row(
                        label: t.trackingIdLabel,
                        value: result.registrationId,
                      ),
                      if (result.message.isNotEmpty)
                        _Row(label: t.messageLabel, value: result.message),
                      if (result.queuedOffline)
                        _Row(
                          label: t.helpSupportOfflineQueueTitle,
                          value: '${t.trackingIdLabel}: $queueId',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(t.registrationSubmittedNote),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    context.go('${RoutePaths.authLogin}?role=voter'),
                icon: const Icon(Icons.login),
                label: Text(t.goToVoterLogin),
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
                label: Text(t.backToPublicPortal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations t, String status) {
    final normalized = status.trim().toLowerCase();
    return switch (normalized) {
      'queued_offline' => t.helpSupportOfflineQueueTitle,
      'pending' => t.registrationStatusPending,
      'approved' => t.registrationStatusApproved,
      'rejected' => t.registrationStatusRejected,
      _ => normalized.isEmpty ? t.registrationStatusPending : status,
    };
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final displayValue = value.isEmpty ? t.unknown : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(displayValue, softWrap: true),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  displayValue,
                  textAlign: TextAlign.end,
                  softWrap: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
