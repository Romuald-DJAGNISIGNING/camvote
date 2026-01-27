import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../shared/policy/device_identity_policy.dart';
import '../../../shared/policy/vote_attempt_policy.dart';
import '../../../shared/security/hash_utils.dart';
import '../domain/election.dart';
import '../domain/vote_receipt.dart';
import '../providers/voter_portal_providers.dart';
import 'voter_receipt_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../shared/biometrics/biometric_support_provider.dart';
import '../../../core/routing/route_paths.dart';
import 'package:go_router/go_router.dart';

class VoterVoteScreen extends ConsumerWidget {
  const VoterVoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final electionsAsync = ref.watch(voterElectionsProvider);
    final biometricSupport = ref.watch(biometricSupportProvider);

    return electionsAsync.when(
      loading: () => const Center(
        child: CamElectionLoader(size: 72, strokeWidth: 6),
      ),
      error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
      data: (elections) {
        final open = elections.where((e) => e.status == ElectionStatus.open);

        return BrandBackdrop(
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.voterVote,
                  subtitle: t.voteBiometricsSubtitle,
                ),
                const SizedBox(height: 12),
                if (biometricSupport.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CamElectionLoader(size: 48, strokeWidth: 5),
                    ),
                  ),
                if (!biometricSupport.isLoading &&
                    (biometricSupport.value ?? false) == false) ...[
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
                if (open.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t.noOpenElections),
                    ),
                  )
                else if ((biometricSupport.value ?? true))
                  ...open.map((e) => _OpenElectionVoteCard(election: e)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OpenElectionVoteCard extends ConsumerWidget {
  final Election election;
  const _OpenElectionVoteCard({required this.election});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final voted = ref.watch(votedElectionIdsProvider).contains(election.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(election.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(t.electionScopeLabel(election.scopeLabel)),
            const SizedBox(height: 12),
            if (voted)
              Text(t.alreadyVotedInElection)
            else
              Column(
                children: election.candidates.map((c) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.how_to_vote_outlined),
                      title: Text(c.fullName),
                      subtitle: Text('${c.partyAcronym} • ${c.partyName}'),
                      trailing: FilledButton(
                        onPressed: () => _secureVoteFlow(context, ref, c),
                        child: Text(t.voteAction),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _secureVoteFlow(
    BuildContext context,
    WidgetRef ref,
    Candidate c,
  ) async {
    final t = AppLocalizations.of(context);
    // Device ban / identity policy (prototype UX layer)
    final policy = DeviceIdentityPolicy();
    if (await policy.isBanned()) {
      final until = await policy.bannedUntil();
      if (!context.mounted) return;
      final untilLabel = until == null ? '' : _formatUntil(context, until);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            until == null
                ? t.deviceBlockedMessage
                : '${t.deviceBlockedMessage} ${t.deviceBlockedUntil(untilLabel)}',
          ),
        ),
      );
      return;
    }

    // Per-election flagging (local enforcement)
    final attemptPolicy = VoteAttemptPolicy();
    if (await attemptPolicy.isFlagged(election.id)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.electionLockedOnDevice)),
      );
      return;
    }

    // Confirm intent first
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t.confirmVoteTitle),
            content: Text(
              t.confirmVoteBody(c.fullName, c.partyAcronym),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.continueNext),
              ),
            ],
          ),
        ) ??
        false;

    if (!context.mounted) return;
    if (!ok) return;

    // 1) Biometric gate
    final bio = BiometricGate();
    final supported = await bio.isSupported();
    if (!context.mounted) return;
    if (!supported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.biometricNotAvailable)),
      );
      return;
    }
    final bioOk = await bio.requireBiometric(
      reason: t.voteBiometricReason,
    );
    if (!context.mounted) return;
    if (!bioOk) {
      await attemptPolicy.recordFailure(election.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.biometricVerificationFailed)),
      );
      return;
    }

    // 2) Liveness gate (prototype)
    final liveOk = await LivenessChallengeScreen.run(context);
    if (!context.mounted) return;
    if (!liveOk) {
      await attemptPolicy.recordFailure(election.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.livenessCheckFailed)),
      );
      return;
    }

    // One-person-one-vote local enforcement
    final alreadyVoted =
        ref.read(votedElectionIdsProvider).contains(election.id);
    if (alreadyVoted) {
      await attemptPolicy.recordDuplicateAttempt(election.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.alreadyVotedInElection)),
        );
      }
      return;
    }

    await ref.read(votedElectionIdsProvider.notifier).markVoted(election.id);
    await attemptPolicy.clear(election.id);

    // Privacy-preserving receipt
    final auditToken = HashUtils.auditToken(
      electionId: election.id,
      candidateId: c.id,
    );
    final receipt = VoteReceipt(
      id: HashUtils.saltedHash(auditToken),
      electionId: election.id,
      electionTitle: election.title,
      candidateHash: HashUtils.saltedHash(c.fullName),
      partyHash: HashUtils.saltedHash(c.partyName),
      auditToken: auditToken,
      castAt: DateTime.now(),
    );
    await ref.read(voteReceiptsProvider.notifier).addReceipt(receipt);

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VoterReceiptScreen(receipt: receipt),
        ),
      );
    }
  }

  String _formatUntil(BuildContext context, DateTime until) {
    final date = MaterialLocalizations.of(context).formatMediumDate(until);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(until),
    );
    return '$date $time';
  }
}
