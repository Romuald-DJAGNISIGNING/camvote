import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/motion/cam_reveal.dart';
import '../../../core/widgets/loaders/cameroon_election_loader.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/branding/brand_backdrop.dart';
import '../../../core/branding/brand_header.dart';
import '../domain/cam_notification.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_app_bar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  IconData _icon(CamNotificationType t) {
    return switch (t) {
      CamNotificationType.info => Icons.info_rounded,
      CamNotificationType.success => Icons.check_circle_rounded,
      CamNotificationType.warning => Icons.warning_rounded,
      CamNotificationType.alert => Icons.priority_high_rounded,
      CamNotificationType.election => Icons.how_to_vote_rounded,
      CamNotificationType.security => Icons.security_rounded,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final state = ref.watch(notificationsControllerProvider);
    final items = ref.watch(filteredNotificationsProvider);
    final audience = ref.watch(activeAudienceProvider);

    return Scaffold(
      appBar: NotificationAppBar(
        title: Text(t.notificationsTitle),
        showBell: false,
        actions: [
          IconButton(
            tooltip: t.markAllRead,
            onPressed: items.isEmpty ? null : () => ref.read(notificationsControllerProvider.notifier).markAllRead(),
            icon: const Icon(Icons.done_all_rounded),
          ),
          IconButton(
            tooltip: t.clearAll,
            onPressed: items.isEmpty ? null : () => ref.read(notificationsControllerProvider.notifier).clearAll(),
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: BrandBackdrop(
        child: state.loading
            ? const Center(child: CamElectionLoader())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return ResponsiveContent(
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          BrandHeader(
                            title: t.notificationsTitle,
                            subtitle: 'Security, elections, and system updates.',
                          ),
                          const SizedBox(height: 12),
                          // Role filter chips (public/voter/observer/admin)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: CamAudience.values.map((a) {
                                  final selected = a == audience;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      selected: selected,
                                      onSelected: (_) => ref
                                          .read(activeAudienceProvider.notifier)
                                          .setAudience(a),
                                      label: Text(_audienceLabel(a, t)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: items.isEmpty
                                ? Center(child: Text(t.noNotifications))
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 8, 0, 20),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final n = items[index];

                                      return CamReveal(
                                        delay: Duration(milliseconds: 40 * index),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Dismissible(
                                            key: ValueKey(n.id),
                                            direction:
                                                DismissDirection.endToStart,
                                            background: Container(
                                              alignment: Alignment.centerRight,
                                              padding:
                                                  const EdgeInsets.only(right: 16),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .errorContainer,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                Icons.delete_rounded,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onErrorContainer,
                                              ),
                                            ),
                                            onDismissed: (_) => ref
                                                .read(
                                                  notificationsControllerProvider
                                                      .notifier,
                                                )
                                                .remove(n.id),
                                            child: _NotificationTile(
                                              icon: _icon(n.type),
                                              title: n.title,
                                              body: n.body,
                                              time: _timeLabel(n.createdAt),
                                              unread: !n.read,
                                              onTap: () async {
                                                await ref
                                                    .read(
                                                      notificationsControllerProvider
                                                          .notifier,
                                                    )
                                                    .markRead(n.id);

                                                // Optional deep link route:
                                                if (n.route != null &&
                                                    context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
}

String _audienceLabel(CamAudience audience, AppLocalizations t) {
  return switch (audience) {
    CamAudience.public => t.audiencePublic,
    CamAudience.voter => t.audienceVoter,
    CamAudience.observer => t.audienceObserver,
    CamAudience.admin => t.audienceAdmin,
    CamAudience.all => t.audienceAll,
  };
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: unread ? cs.primaryContainer.withAlpha(20) : cs.surfaceContainerHighest.withAlpha(60),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(time, style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(body, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
