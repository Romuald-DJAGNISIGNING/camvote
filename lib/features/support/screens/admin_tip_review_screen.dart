import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/feedback/cam_toast.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../models/admin_tip_record.dart';
import '../providers/admin_tip_providers.dart';

class AdminTipReviewScreen extends ConsumerStatefulWidget {
  const AdminTipReviewScreen({super.key});

  @override
  ConsumerState<AdminTipReviewScreen> createState() =>
      _AdminTipReviewScreenState();
}

class _AdminTipReviewScreenState extends ConsumerState<AdminTipReviewScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tipsAsync = ref.watch(adminTipsProvider);
    final statusFilter = ref.watch(adminTipStatusFilterProvider);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.adminTipReviewTitle),
        actions: [
          IconButton(
            tooltip: t.refresh,
            onPressed: _busy
                ? null
                : () {
                    ref.invalidate(adminTipsProvider);
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 6),
              BrandHeader(
                title: t.adminTipReviewTitle,
                subtitle: t.adminTipReviewSubtitle,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    initialValue: statusFilter,
                    decoration: InputDecoration(
                      labelText: t.filterStatus,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text(t.adminTipFilterAll),
                      ),
                      DropdownMenuItem(
                        value: 'submitted',
                        child: Text(t.adminTipFilterSubmitted),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text(t.adminTipFilterPending),
                      ),
                      DropdownMenuItem(
                        value: 'success',
                        child: Text(t.adminTipFilterSuccess),
                      ),
                      DropdownMenuItem(
                        value: 'failed',
                        child: Text(t.adminTipFilterFailed),
                      ),
                    ],
                    onChanged: (value) {
                      ref
                          .read(adminTipStatusFilterProvider.notifier)
                          .setStatus(value ?? '');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              tipsAsync.when(
                data: (tips) {
                  if (tips.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(t.adminTipNoTips),
                      ),
                    );
                  }
                  return Column(
                    children: tips
                        .map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TipCard(
                              tip: tip,
                              t: t,
                              busy: _busy,
                              onApprove: () => _decide(tip, 'success'),
                              onReject: () => _decide(tip, 'failed'),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CamElectionLoader()),
                error: (error, _) =>
                    Center(child: Text(safeErrorMessage(context, error))),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _decide(AdminTipRecord tip, String decision) async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            decision == 'success'
                ? t.adminTipApproveTitle
                : t.adminTipRejectTitle,
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: t.adminTipDecisionNoteLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(t.ok),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (note == null) return;

    setState(() => _busy = true);
    try {
      final result = await ref
          .read(adminTipDecisionProvider)
          .decide(tipId: tip.id, decision: decision, note: note);
      if (!mounted) return;
      if (result.queuedOffline) {
        final queueRef = result.offlineQueueId.isEmpty
            ? tip.id
            : result.offlineQueueId;
        CamToast.show(
          context,
          message: t.offlineQueuedWithReference(queueRef),
          type: CamToastType.info,
        );
      } else {
        CamToast.show(context, message: t.adminTipDecisionSuccess);
      }
    } catch (error) {
      if (!mounted) return;
      CamToast.show(context, message: safeErrorMessage(context, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.t,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final AdminTipRecord tip;
  final AppLocalizations t;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountLabel = '${tip.amount} ${tip.currency}';
    final statusLabel = tip.status.isEmpty ? t.statusUnknown : tip.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tip.anonymous
                        ? t.tipAnonymousSupporterName
                        : tip.senderName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(statusLabel)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              [
                amountLabel,
                tip.provider,
              ].where((v) => v.isNotEmpty).join(' | '),
              style: theme.textTheme.bodySmall,
            ),
            if (tip.reference.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${t.tipReferenceLabel}: ${tip.reference}'),
            ],
            if (tip.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(tip.note),
            ],
            if (tip.receiptUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.tipReceiptUploadedCount(tip.receiptUrls.length)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(tip.receiptUrls.length, (index) {
                  final url = tip.receiptUrls[index];
                  return OutlinedButton.icon(
                    onPressed: () => _openReceipt(context, url, t),
                    icon: const Icon(Icons.open_in_new),
                    label: Text('${t.tipReceiptLabel} ${index + 1}'),
                  );
                }),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : onReject,
                  icon: const Icon(Icons.close),
                  label: Text(t.reject),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: busy ? null : onApprove,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(t.approve),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openReceipt(
  BuildContext context,
  String url,
  AppLocalizations t,
) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) {
    CamToast.show(context, message: t.openLinkFailed);
    return;
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!context.mounted) return;
  if (!ok) {
    CamToast.show(context, message: t.openLinkFailed);
  }
}
