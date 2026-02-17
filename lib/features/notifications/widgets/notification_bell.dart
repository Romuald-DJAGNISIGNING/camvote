import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../providers/notifications_providers.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({
    super.key,
    required this.onOpen,
    this.showTooltip = true,
    this.compact = false,
  });

  final VoidCallback onOpen;
  final bool showTooltip;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    int unread;
    try {
      unread = ref
          .watch(filteredNotificationsProvider)
          .where((item) => !item.read)
          .length;
    } catch (_) {
      unread = 0;
    }

    return IconButton(
      style: compact
          ? IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              iconSize: 19,
              minimumSize: const Size(34, 34),
              padding: const EdgeInsets.all(7),
            )
          : null,
      tooltip: showTooltip ? t.notificationsTitle : null,
      onPressed: () {
        try {
          ref.read(notificationsControllerProvider.notifier).syncFromServer();
        } catch (_) {
          // Notifications should never block navigation.
        }
        onOpen();
      },
      icon: unread == 0
          ? const Icon(Icons.notifications_none_rounded)
          : Badge(
              label: Text('$unread'),
              child: const Icon(Icons.notifications_rounded),
            ),
    );
  }
}
