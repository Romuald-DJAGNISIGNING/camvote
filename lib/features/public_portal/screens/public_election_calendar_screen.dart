import 'package:camvote/core/errors/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
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
            error: (e, _) =>
                Center(child: Text(safeErrorMessage(context, e))),
            data: (items) => ListView(
              padding: EdgeInsets.zero,
              children: [
                CamStagger(
                  children: [
                    const SizedBox(height: 6),
                    BrandHeader(
                      title: t.publicElectionCalendarTitle,
                      subtitle: t.publicElectionCalendarSubtitle,
                    ),
                    const SizedBox(height: 12),
                    CamSectionHeader(
                      title: t.publicElectionCalendarTitle,
                      subtitle: t.publicElectionCalendarSubtitle,
                      icon: Icons.event_available_outlined,
                    ),
                    const SizedBox(height: 6),
                    if (items.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(t.noData),
                        ),
                      )
                    else
                      ...items.map(
                        (item) => CamReveal(
                          child: _EventCard(
                            title: item.title,
                            subtitle: t.calendarEntrySubtitle(
                              item.scope,
                              item.location,
                              dateFormat.format(item.startAt),
                              dateFormat.format(item.endAt),
                            ),
                            status: item.status,
                            dateLabel: dateFormat.format(item.startAt),
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateLabel,
  });

  final String title;
  final String subtitle;
  final String status;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(cs, status);

    return Card(
      child: ListTile(
        leading: _DateBadge(label: dateLabel),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Chip(
          label: Text(status),
          backgroundColor: statusColor.withAlpha(22),
          labelStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: statusColor),
          side: BorderSide(color: statusColor.withAlpha(90)),
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme cs, String value) {
    final key = value.trim().toLowerCase();
    if (key.contains('open') || key.contains('ongoing')) {
      return cs.tertiary;
    }
    if (key.contains('closed') || key.contains('ended')) {
      return cs.outline;
    }
    return cs.primary;
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withAlpha(60)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}


