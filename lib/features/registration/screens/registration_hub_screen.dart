import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../providers/registration_providers.dart';
import '../../../shared/biometrics/biometric_support_provider.dart';
import '../../../core/theme/role_theme.dart';

class RegistrationHubScreen extends ConsumerStatefulWidget {
  const RegistrationHubScreen({super.key});

  @override
  ConsumerState<RegistrationHubScreen> createState() =>
      _RegistrationHubScreenState();
}

class _RegistrationHubScreenState extends ConsumerState<RegistrationHubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(registrationEnrollmentProvider.notifier).loadEnrollment(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceIds = ref.watch(deviceAccountIdsProvider);
    final enrollment = ref.watch(registrationEnrollmentProvider);
    final t = AppLocalizations.of(context);
    final biometricSupport = ref.watch(biometricSupportProvider);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.registrationHubTitle)),
      body: deviceIds.when(
        data: (ids) {
          final biometricOk = biometricSupport.value ?? true;
          final canCreate = ids.length < 2 && biometricOk;

          return BrandBackdrop(
            child: ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.registrationHubTitle,
                        subtitle: t.registrationHubSubtitle,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.phonelink_lock),
                          title: Text(t.deviceAccountPolicyTitle),
                          subtitle: Text(
                            t.deviceAccountPolicyBody(ids.length, 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (biometricSupport.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CamElectionLoader(size: 48, strokeWidth: 5),
                          ),
                        ),
                      if (!biometricSupport.isLoading && !biometricOk) ...[
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber_outlined),
                            title: Text(t.biometricsUnavailableTitle),
                            subtitle: Text(t.biometricsUnavailableBody),
                            trailing: IconButton(
                              tooltip: t.votingCentersTitle,
                              icon: const Icon(Icons.map_outlined),
                              onPressed: () =>
                                  context.go(RoutePaths.publicVotingCenters),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Card(
                        child: ListTile(
                          leading: Icon(
                            enrollment.isComplete
                                ? Icons.verified_outlined
                                : Icons.security_outlined,
                          ),
                          title: Text(t.biometricEnrollmentTitle),
                          subtitle: Text(
                            enrollment.isComplete
                                ? t.biometricEnrollmentStatusComplete
                                : t.biometricEnrollmentStatusPending,
                          ),
                          trailing: Chip(
                            label: Text(
                              enrollment.isComplete
                                  ? t.statusComplete
                                  : t.statusPending,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!canCreate)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.registrationBlockedTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(t.registrationBlockedBody),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: canCreate
                            ? () => context.go(RoutePaths.registerVoter)
                            : null,
                        icon: const Icon(Icons.how_to_vote),
                        label: Text(t.startVoterRegistration),
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
                        label: Text(t.backToPublicMode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        error: (e, _) => Center(child: Text(safeErrorMessage(context, e))),
        loading: () => const Center(child: CamElectionLoader()),
      ),
    );
  }
}


