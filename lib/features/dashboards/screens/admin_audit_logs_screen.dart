import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';
import 'package:camvote/core/errors/error_message.dart';

import '../models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../../../core/motion/cam_reveal.dart';
import '../../notifications/widgets/notification_app_bar.dart';

class AdminAuditLogsScreen extends ConsumerWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(auditEventsProvider);
    final selected = ref.watch(auditFilterProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.auditLogsTitle),
        actions: [
          PopupMenuButton<AuditEventType?>(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(t.auditFilterAll)),
              ...AuditEventType.values.map(
                (event) => PopupMenuItem(
                  value: event,
                  child: Text(_eventLabel(t, event)),
                ),
              ),
            ],
            onSelected: (v) =>
                ref.read(auditFilterProvider.notifier).setFilter(v),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.shield, size: 18),
                const SizedBox(width: 8),
                Text(
                  selected == null
                      ? t.auditShowingAll
                      : t.auditFilterLabel(_eventLabel(t, selected)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BrandBackdrop(
        child: events.when(
          data: (items) {
            return ResponsiveContent(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CamStagger(
                    children: [
                      const SizedBox(height: 6),
                      BrandHeader(
                        title: t.auditLogsTitle,
                        subtitle: t.auditLogsSubtitle,
                      ),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(t.noAuditEvents),
                          ),
                        )
                      else
                        ...items.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: ListTile(
                                leading: Icon(_iconFor(e.type)),
                                title: Text(e.message),
                                subtitle: Text(
                                  '${e.actorRole.toUpperCase()} • ${_formatDateTime(context, e.at)} • ${_eventLabel(t, e.type)}',
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 18),
                    ],
                  ),
                ],
              ),
            );
          },
          error: (e, _) =>
              Center(child: Text(safeErrorMessage(context, e))),
          loading: () => const Center(child: CamElectionLoader()),
        ),
      ),
    );
  }

  static IconData _iconFor(AuditEventType t) => switch (t) {
    AuditEventType.electionCreated => Icons.how_to_vote,
    AuditEventType.candidateAdded => Icons.person_add,
    AuditEventType.resultsPublished => Icons.public,
    AuditEventType.listCleaned => Icons.cleaning_services,
    AuditEventType.registrationApproved => Icons.verified_user,
    AuditEventType.registrationRejected => Icons.block,
    AuditEventType.suspiciousActivity => Icons.warning_amber,
    AuditEventType.deviceBanned => Icons.phonelink_erase,
    AuditEventType.voteCast => Icons.check_circle,
    AuditEventType.roleChanged => Icons.manage_accounts_outlined,
  };

  String _eventLabel(AppLocalizations t, AuditEventType type) {
    return switch (type) {
      AuditEventType.electionCreated => t.auditEventElectionCreated,
      AuditEventType.candidateAdded => t.auditEventCandidateAdded,
      AuditEventType.resultsPublished => t.auditEventResultsPublished,
      AuditEventType.listCleaned => t.auditEventListCleaned,
      AuditEventType.registrationApproved => t.auditEventRegistrationApproved,
      AuditEventType.registrationRejected => t.auditEventRegistrationRejected,
      AuditEventType.suspiciousActivity => t.auditEventSuspiciousActivity,
      AuditEventType.deviceBanned => t.auditEventDeviceBanned,
      AuditEventType.voteCast => t.auditEventVoteCast,
      AuditEventType.roleChanged => t.auditEventRoleChanged,
    };
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date $time';
  }
}


