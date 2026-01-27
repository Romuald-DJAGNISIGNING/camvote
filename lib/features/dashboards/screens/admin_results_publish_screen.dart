import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class AdminResultsPublishScreen extends ConsumerWidget {
  const AdminResultsPublishScreen({super.key});

  Future<void> _publish(
    BuildContext context,
    WidgetRef ref,
    String electionId,
  ) async {
    final t = AppLocalizations.of(context);
    try {
      await ref.read(toolsRepositoryProvider).publishResults(electionId);
      ref.invalidate(adminResultsPublishingProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.resultsPublishedToast)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.errorWithDetails(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(adminResultsPublishingProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.adminResultsPublishTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: results.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.adminResultsPublishTitle,
                  subtitle: t.adminResultsPublishSubtitle,
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(t.noData),
                    ),
                  )
                else
                  ...items.map(
                    (item) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.rocket_launch_outlined),
                        title: Text(item.electionTitle),
                        subtitle: Text(
                          t.resultsPublishSummary(
                            item.totalVotes,
                            item.precinctsReporting,
                          ),
                        ),
                        trailing: item.readyToPublish
                            ? FilledButton(
                                onPressed: () => _publish(
                                  context,
                                  ref,
                                  item.electionId,
                                ),
                                child: Text(t.publishResultsAction),
                              )
                            : Text(t.resultsPublishNotReady),
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
