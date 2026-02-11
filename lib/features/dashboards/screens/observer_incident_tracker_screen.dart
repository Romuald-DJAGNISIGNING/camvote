import 'package:camvote/core/errors/error_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/sections/cam_section_header.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../notifications/widgets/notification_app_bar.dart';
import '../../tools/providers/tools_providers.dart';

class ObserverIncidentTrackerScreen extends ConsumerWidget {
  const ObserverIncidentTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(observerIncidentFilterProvider);
    final incidents = ref.watch(observerIncidentsProvider(filter));
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(title: Text(t.observerIncidentTrackerTitle)),
      body: BrandBackdrop(
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              CamStagger(
                children: [
                  const SizedBox(height: 6),
                  BrandHeader(
                    title: t.observerIncidentTrackerTitle,
                    subtitle: t.observerIncidentTrackerSubtitle,
                  ),
                  const SizedBox(height: 12),
                  CamSectionHeader(
                    title: t.filterLabel,
                    icon: Icons.filter_alt_outlined,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _FilterRow(
                        value: filter,
                        onChanged: (value) => ref
                            .read(observerIncidentFilterProvider.notifier)
                            .setFilter(value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  incidents.when(
                    loading: () => const Center(child: CamElectionLoader()),
                    error: (e, _) =>
                        Center(child: Text(safeErrorMessage(context, e))),
                    data: (items) {
                      if (items.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(t.noData),
                          ),
                        );
                      }
                      return Column(
                        children: items
                            .map(
                              (item) => Card(
                                child: ListTile(
                                  leading: const Icon(Icons.report_outlined),
                                  title: Text(item.title),
                                  subtitle: Text(
                                    t.incidentSubtitle(
                                      item.severity,
                                      item.location,
                                    ),
                                  ),
                                  trailing: Text(item.status),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = ['all', 'open', 'investigating', 'resolved'];

    return Row(
      children: [
        Text(t.filterLabel),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: value,
          onChanged: (next) => next == null ? null : onChanged(next),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(_labelForOption(t, option)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _labelForOption(AppLocalizations t, String option) {
    return switch (option) {
      'open' => t.incidentStatusOpen,
      'investigating' => t.incidentStatusInvestigating,
      'resolved' => t.incidentStatusResolved,
      _ => t.filterAll,
    };
  }
}


