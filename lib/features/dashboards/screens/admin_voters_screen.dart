import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../utils/fraud_risk.dart';

class AdminVotersScreen extends ConsumerWidget {
  const AdminVotersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voters = ref.watch(votersProvider);
    final q = ref.watch(votersQueryProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.adminVoterManagementTitle),
        actions: [
          IconButton(
            tooltip: t.adminRunListCleaningTooltip,
            onPressed: () async {
              await ref.read(listCleaningControllerProvider).runCleaning();
              if (context.mounted) {
                CamToast.show(context, message: t.adminListCleaningDone);
              }
            },
            icon: const Icon(Icons.cleaning_services),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ResponsiveContent(
              child: SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    CamStagger(
                      children: [
                        const SizedBox(height: 6),
                        BrandHeader(
                          title: t.adminVoterManagementTitle,
                          subtitle: t.adminVoterManagementSubtitle,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: t.voterSearchHint,
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.search),
                                    ),
                                    onChanged: (v) => ref
                                        .read(votersQueryProvider.notifier)
                                        .update(q.copyWith(query: v)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.filter_alt),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'region',
                                      child: Text(t.filterRegion),
                                    ),
                                    PopupMenuItem(
                                      value: 'status',
                                      child: Text(t.filterStatus),
                                    ),
                                    PopupMenuItem(
                                      value: 'clear',
                                      child: Text(t.clearFilters),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'clear') {
                                      ref
                                          .read(votersQueryProvider.notifier)
                                          .update(
                                            q.copyWith(
                                              clearRegion: true,
                                              clearStatus: true,
                                              query: q.query,
                                            ),
                                          );
                                      return;
                                    }
                                    if (value == 'region') {
                                      final picked = await _pickRegion(
                                        context,
                                        q.region,
                                      );
                                      if (picked == null) return;
                                      ref
                                          .read(votersQueryProvider.notifier)
                                          .update(q.copyWith(region: picked));
                                      return;
                                    }
                                    if (value == 'status') {
                                      final picked = await _pickStatus(
                                        context,
                                        q.status,
                                      );
                                      if (picked == null) return;
                                      ref
                                          .read(votersQueryProvider.notifier)
                                          .update(q.copyWith(status: picked));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (q.region != null || q.status != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (q.region != null)
                                  Chip(
                                    label: Text(
                                      t.regionFilterLabel(
                                        _regionLabel(t, q.region!),
                                      ),
                                    ),
                                  ),
                                if (q.status != null)
                                  Chip(
                                    label: Text(
                                      t.statusFilterLabel(
                                        _statusLabel(t, q.status!),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    Expanded(
                      child: voters.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return Center(child: Text(t.noVotersMatchFilters));
                          }

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final v = items[i];
                              final flags = <String>[
                                if (v.deviceFlagged) t.deviceFlaggedLabel,
                                if (v.biometricDuplicateFlag)
                                  t.biometricDuplicateLabel,
                              ];

                              final risk = FraudRiskEngine.evaluate(v);
                              final regionLabel = _regionLabel(t, v.region);
                              final statusLabel = _statusLabel(t, v.status);
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      v.fullName.isNotEmpty
                                          ? v.fullName[0].toUpperCase()
                                          : 'V',
                                    ),
                                  ),
                                  title: Text('${v.fullName} • ${v.voterId}'),
                                  subtitle: Text(
                                    '$regionLabel • ${t.ageLabel(v.age)} • $statusLabel'
                                    '${flags.isEmpty ? '' : '\n${t.flagsLabel(flags.join(' • '))}'}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _RiskChip(risk: risk),
                                      Icon(
                                        v.verified
                                            ? Icons.verified
                                            : Icons.hourglass_top,
                                        color: v.verified
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        v.hasVoted
                                            ? t.voterHasVotedLabel
                                            : t.voterNotVotedLabel,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall,
                                      ),
                                      if ((v.registrationId ?? '').isNotEmpty &&
                                          (v.status ==
                                                  VoterStatus
                                                      .pendingVerification ||
                                              v.verified == false)) ...[
                                        const SizedBox(height: 6),
                                        PopupMenuButton<String>(
                                          onSelected: (action) async {
                                            await _handleDecision(
                                              context: context,
                                              ref: ref,
                                              approve: action == 'approve',
                                              registrationId:
                                                  v.registrationId ?? '',
                                              voterId: v.voterId,
                                            );
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'approve',
                                              child: Text(t.approveAction),
                                            ),
                                            PopupMenuItem(
                                              value: 'reject',
                                              child: Text(t.rejectAction),
                                            ),
                                          ],
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        error: (e, _) => Center(
                          child: Text(safeErrorMessage(context, e)),
                        ),
                        loading: () => const Center(child: CamElectionLoader()),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<CameroonRegion?> _pickRegion(
    BuildContext context,
    CameroonRegion? selected,
  ) async {
    final t = AppLocalizations.of(context);
    return showDialog<CameroonRegion>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(t.chooseRegionTitle),
          children: [
            RadioGroup<CameroonRegion>(
              groupValue: selected,
              onChanged: (value) => Navigator.pop(ctx, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: CameroonRegion.values
                    .map(
                      (r) => RadioListTile<CameroonRegion>(
                        value: r,
                        title: Text(_regionLabel(t, r)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<VoterStatus?> _pickStatus(
    BuildContext context,
    VoterStatus? selected,
  ) async {
    final t = AppLocalizations.of(context);
    return showDialog<VoterStatus>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(t.chooseStatusTitle),
          children: [
            RadioGroup<VoterStatus>(
              groupValue: selected,
              onChanged: (value) => Navigator.pop(ctx, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: VoterStatus.values
                    .map(
                      (s) => RadioListTile<VoterStatus>(
                        value: s,
                        title: Text(_statusLabel(t, s)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _regionLabel(AppLocalizations t, CameroonRegion region) {
  return switch (region) {
    CameroonRegion.adamawa => t.regionAdamawa,
    CameroonRegion.centre => t.regionCentre,
    CameroonRegion.east => t.regionEast,
    CameroonRegion.farNorth => t.regionFarNorth,
    CameroonRegion.littoral => t.regionLittoral,
    CameroonRegion.north => t.regionNorth,
    CameroonRegion.northWest => t.regionNorthWest,
    CameroonRegion.south => t.regionSouth,
    CameroonRegion.southWest => t.regionSouthWest,
    CameroonRegion.west => t.regionWest,
  };
}

Future<void> _handleDecision({
  required BuildContext context,
  required WidgetRef ref,
  required bool approve,
  required String registrationId,
  required String voterId,
}) async {
  final t = AppLocalizations.of(context);
  try {
    await ref.read(adminRepositoryProvider).decideRegistration(
          registrationId: registrationId,
          approve: approve,
          voterId: voterId,
        );
    ref.invalidate(votersProvider);
    ref.invalidate(adminStatsProvider);
    ref.invalidate(auditEventsProvider);
    if (context.mounted) {
      CamToast.show(
        context,
        message:
            approve ? t.registrationStatusApproved : t.registrationStatusRejected,
      );
    }
  } catch (_) {
    if (context.mounted) {
      CamToast.show(context, message: t.genericErrorLabel);
    }
  }
}

String _statusLabel(AppLocalizations t, VoterStatus status) {
  return switch (status) {
    VoterStatus.pendingVerification => t.statusPendingVerification,
    VoterStatus.registered => t.statusRegistered,
    VoterStatus.preEligible => t.statusPreEligible,
    VoterStatus.eligible => t.statusEligible,
    VoterStatus.voted => t.statusVoted,
    VoterStatus.suspended => t.statusSuspended,
    VoterStatus.deceased => t.statusDeceased,
    VoterStatus.archived => t.statusArchived,
  };
}

class _RiskChip extends StatelessWidget {
  final FraudRisk risk;

  const _RiskChip({required this.risk});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = risk.color(cs);
    final t = AppLocalizations.of(context);
    final label = switch (risk.level) {
      FraudRiskLevel.low => t.riskLow,
      FraudRiskLevel.medium => t.riskMedium,
      FraudRiskLevel.high => t.riskHigh,
      FraudRiskLevel.critical => t.riskCritical,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        t.riskLabel(label),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}




