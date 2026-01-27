import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class ObserverChecklistScreen extends ConsumerWidget {
  const ObserverChecklistScreen({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    String id,
    bool completed,
  ) async {
    final t = AppLocalizations.of(context);
    try {
      await ref.read(toolsRepositoryProvider).updateChecklistItem(id, completed);
      ref.invalidate(observerChecklistProvider);
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
    final checklist = ref.watch(observerChecklistProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.observerChecklistTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: checklist.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.observerChecklistTitle,
                  subtitle: t.observerChecklistSubtitle,
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
                      child: CheckboxListTile(
                        value: item.completed,
                        onChanged: (value) => value == null
                            ? null
                            : _toggle(context, ref, item.id, value),
                        title: Text(item.title),
                        subtitle: Text(item.description),
                        secondary: item.required
                            ? const Icon(Icons.star_outline)
                            : const Icon(Icons.task_outlined),
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
