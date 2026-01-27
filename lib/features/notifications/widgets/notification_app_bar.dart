import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import 'notification_bell.dart';

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBell;

  const NotificationAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
    this.centerTitle = false,
    this.showBell = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final actionList = <Widget>[
      if (showBell)
        NotificationBell(
          onOpen: () {
            context.push(RoutePaths.notifications);
          },
        ),
      ...?actions,
    ];

    return AppBar(
      title: title,
      centerTitle: centerTitle,
      bottom: bottom,
      actions: actionList.isEmpty ? null : actionList,
    );
  }
}
