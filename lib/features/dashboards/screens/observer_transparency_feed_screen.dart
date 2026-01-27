import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class ObserverTransparencyFeedScreen extends ConsumerWidget {
  const ObserverTransparencyFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(observerTransparencyProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.observerTransparencyTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: feed.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.observerTransparencyTitle,
                  subtitle: t.observerTransparencySubtitle,
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
                        leading: const Icon(Icons.public_outlined),
                        title: Text(item.title),
                        subtitle: Text(item.summary),
                        trailing: Text(item.source),
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
