import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../providers/notifications_providers.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final unread = ref
        .watch(filteredNotificationsProvider)
        .where((item) => !item.read)
        .length;

    return IconButton(
      tooltip: t.notificationsTitle,
      onPressed: () {
        ref.read(notificationsControllerProvider.notifier).syncFromServer();
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
