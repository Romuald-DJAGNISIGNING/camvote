import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/routing/route_paths.dart';
import '../models/registration_submission_result.dart';

class VoterRegistrationSubmittedScreen extends StatelessWidget {
  final RegistrationSubmissionResult result;

  const VoterRegistrationSubmittedScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final statusLabel = _statusLabel(t, result.status);
    return Scaffold(
      appBar: AppBar(title: Text(t.registrationSubmittedTitle)),
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
                      _Row(label: t.trackingIdLabel, value: result.registrationId),
                      if (result.message.isNotEmpty)
                        _Row(label: t.messageLabel, value: result.message),
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
                onPressed: () => context.go(RoutePaths.publicHome),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(value.isEmpty ? t.unknown : value),
        ],
      ),
    );
  }
}
