import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import 'notification_bell.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBell;
  final bool showBack;

  const NotificationAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
    this.centerTitle = false,
    this.showBell = true,
    this.showBack = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
      automaticallyImplyLeading: false,
      forceMaterialTransparency: kIsWeb,
      leading: showBack ? const AppBackButton(alwaysVisible: false) : null,
      title: title,
      centerTitle: centerTitle,
      bottom: bottom,
      backgroundColor: kIsWeb ? Colors.transparent : null,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: kIsWeb
          ? null
          : Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(60))),
      actions: actionList.isEmpty ? null : actionList,
    );
  }
}
