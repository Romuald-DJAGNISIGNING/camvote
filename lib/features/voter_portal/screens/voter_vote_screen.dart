import 'package:camvote/core/errors/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/biometrics/biometric_gate.dart';
import '../../../shared/liveness/liveness_challenge_screen.dart';
import '../../../shared/policy/device_identity_policy.dart';
import '../../../shared/policy/vote_attempt_policy.dart';
import '../../../shared/security/hash_utils.dart';
import '../../../shared/security/device_fingerprint.dart';
import '../../../shared/security/device_key_manager.dart';
import '../domain/election.dart';
import '../domain/vote_receipt.dart';
import '../providers/voter_portal_providers.dart';
import 'voter_receipt_screen.dart';
import 'voter_vote_impact_screen.dart';
import '../../../core/layout/responsive.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../shared/biometrics/biometric_support_provider.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/network/worker_client.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import 'package:go_router/go_router.dart';

class VoterVoteScreen extends ConsumerWidget {
  const VoterVoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final electionsAsync = ref.watch(voterElectionsProvider);
    final biometricSupport = ref.watch(biometricSupportProvider);

    return electionsAsync.when(
      loading: () =>
          const Center(child: CamElectionLoader(size: 72, strokeWidth: 6)),
      error: (e, _) => Center(child: Text(safeErrorMessage(context, e))),
      data: (elections) {
        final open = elections.where((e) => e.status == ElectionStatus.open);

        return BrandBackdrop(
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CamStagger(
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
                        child: ListTile(
                          leading: const Icon(Icons.event_busy),
                          title: Text(t.noOpenElections),
                        ),
                      )
                    else if ((biometricSupport.value ?? true))
                      ...open.map((e) => _OpenElectionVoteCard(election: e)),
                  ],
                ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  t.alreadyVotedInElection,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else ...[
              CamSectionHeader(
                title: t.candidatesLabel,
                icon: Icons.people_outline,
              ),
              const SizedBox(height: 6),
              ...election.candidates.map((c) {
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
              }),
            ],
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.electionLockedOnDevice)));
      return;
    }

    // Confirm intent first
    if (!context.mounted) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(t.confirmVoteTitle),
            content: Text(t.confirmVoteBody(c.fullName, c.partyAcronym)),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricNotAvailable)));
      return;
    }
    final bioOk = await bio.requireBiometric(reason: t.voteBiometricReason);
    if (!context.mounted) return;
    if (!bioOk) {
      await attemptPolicy.recordFailure(election.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricVerificationFailed)));
      return;
    }

    // 2) Liveness gate (prototype)
    final liveOk = await LivenessChallengeScreen.run(context);
    if (!context.mounted) return;
    if (!liveOk) {
      await attemptPolicy.recordFailure(election.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.livenessCheckFailed)));
      return;
    }

    // One-person-one-vote local enforcement
    final alreadyVoted = ref
        .read(votedElectionIdsProvider)
        .contains(election.id);
    if (alreadyVoted) {
      await attemptPolicy.recordDuplicateAttempt(election.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.alreadyVotedInElection)));
      }
      return;
    }

    // Backend-enforced vote (Cloudflare Worker)
    Map<String, dynamic>? castResponse;
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        throw WorkerException('Sign in required.');
      }

      final deviceHash = await DeviceFingerprint.compute();
      await DeviceKeyManager.ensureKeyPair();
      final publicKey = await DeviceKeyManager.publicKeyBase64();

      final worker = WorkerClient();
      await worker.post(
        '/v1/device/register',
        data: {'deviceHash': deviceHash, 'publicKey': publicKey},
      );

      final nonceRes = await worker.post(
        '/v1/vote/nonce',
        data: {'electionId': election.id, 'deviceHash': deviceHash},
      );

      final nonce = (nonceRes['nonce'] as String?) ?? '';
      final nonceId = (nonceRes['nonceId'] as String?) ?? '';
      if (nonce.isEmpty || nonceId.isEmpty) {
        throw WorkerException('Vote verification failed.');
      }

      final message = DeviceKeyManager.buildVoteMessage(
        nonce: nonce,
        uid: uid,
        electionId: election.id,
        candidateId: c.id,
        deviceHash: deviceHash,
      );
      final signature = await DeviceKeyManager.signMessage(message);

      castResponse = await worker.post(
        '/v1/vote/cast',
        data: {
          'electionId': election.id,
          'candidateId': c.id,
          'deviceHash': deviceHash,
          'nonceId': nonceId,
          'signature': signature,
          'biometricVerified': true,
          'livenessPassed': true,
        },
      );
    } on WorkerException catch (e) {
      await attemptPolicy.recordFailure(election.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    } catch (_) {
      await attemptPolicy.recordFailure(election.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.biometricVerificationFailed)));
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

    final tally = _parseVoteImpactTally(castResponse);

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VoterVoteImpactScreen(
            electionTitle: election.title,
            candidateName: c.fullName,
            tally: tally,
          ),
        ),
      );
    }

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VoterReceiptScreen(receipt: receipt),
        ),
      );
    }
  }

  VoteImpactTally? _parseVoteImpactTally(Map<String, dynamic>? castResponse) {
    if (castResponse == null) return null;
    final raw = castResponse['tally'];
    if (raw is! Map) return null;
    final map = raw.cast<String, dynamic>();
    final after = _safeInt(map['after']);
    if (after < 0) return null;
    final delta = _safeInt(map['delta']);
    final before = _safeInt(map['before']);
    return VoteImpactTally(
      before: before >= 0 ? before : (after - (delta > 0 ? delta : 1)),
      delta: delta > 0 ? delta : 1,
      after: after,
    );
  }

  int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? -1;
  }

  String _formatUntil(BuildContext context, DateTime until) {
    final date = MaterialLocalizations.of(context).formatMediumDate(until);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(until));
    return '$date $time';
  }
}


