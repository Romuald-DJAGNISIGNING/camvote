import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class PublicElectionCalendarScreen extends ConsumerWidget {
  const PublicElectionCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(publicElectionCalendarProvider);
    final t = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd(t.localeName);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.publicElectionCalendarTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: entries.when(
            loading: () => const Center(child: CamElectionLoader()),
            error: (e, _) => Center(child: Text(t.errorWithDetails(e.toString()))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 6),
                BrandHeader(
                  title: t.publicElectionCalendarTitle,
                  subtitle: t.publicElectionCalendarSubtitle,
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
                        leading: const Icon(Icons.event_available_outlined),
                        title: Text(item.title),
                        subtitle: Text(
                          t.calendarEntrySubtitle(
                            item.scope,
                            item.location,
                            dateFormat.format(item.startAt),
                            dateFormat.format(item.endAt),
                          ),
                        ),
                        trailing: Text(item.status),
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
