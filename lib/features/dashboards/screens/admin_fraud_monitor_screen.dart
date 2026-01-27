import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class AdminFraudMonitorScreen extends ConsumerWidget {
  const AdminFraudMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(adminFraudInsightProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.adminFraudMonitorTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: insight.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
            data: (data) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.adminFraudMonitorTitle,
                  subtitle: t.adminFraudMonitorSubtitle,
                ),
                const SizedBox(height: 12),
                CamReveal(
                  child: _ScoreCard(
                    riskScore: data.riskScore,
                    totalSignals: data.totalSignals,
                    devicesFlagged: data.devicesFlagged,
                    accountsAtRisk: data.accountsAtRisk,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.fraudSignalsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (data.signals.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t.noData),
                    ),
                  )
                else
                  ...data.signals.map(
                    (signal) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.bolt_outlined),
                        title: Text(signal.title),
                        subtitle: Text(signal.detail),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.fraudSignalCount(signal.count),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              signal.severity,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.riskScore,
    required this.totalSignals,
    required this.devicesFlagged,
    required this.accountsAtRisk,
  });

  final double riskScore;
  final int totalSignals;
  final int devicesFlagged;
  final int accountsAtRisk;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final pct = (riskScore * 100).clamp(0, 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.fraudRiskScoreTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(t.fraudRiskScoreValue(pct.toStringAsFixed(1))),
            const SizedBox(height: 8),
            Row(
              children: [
                const CamElectionLoader(size: 18, strokeWidth: 2.4),
                const SizedBox(width: 10),
                Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _MetricChip(label: t.fraudSignalTotal, value: totalSignals),
                _MetricChip(label: t.fraudDevicesFlagged, value: devicesFlagged),
                _MetricChip(label: t.fraudAccountsAtRisk, value: accountsAtRisk),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
    );
  }
}
