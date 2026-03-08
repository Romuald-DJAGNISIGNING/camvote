import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/brand_logo.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/role_theme.dart';
import '../../../core/widgets/navigation/app_back_button.dart';
import '../../auth/providers/auth_providers.dart';
import 'notification_bell.dart';

class NotificationAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBell;
  final bool showBack;
  final bool showOnWeb;
  final bool showHomeLogo;

  const NotificationAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
    this.centerTitle = false,
    this.showBell = true,
    this.showBack = true,
    this.showOnWeb = false,
    this.showHomeLogo = true,
  });

  @override
  Size get preferredSize {
    if (kIsWeb && !showOnWeb) return Size.zero;
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb && !showOnWeb) {
      return const SizedBox.shrink();
    }

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
      title: _buildTitle(context, ref),
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

  Widget _buildTitle(BuildContext context, WidgetRef ref) {
    if (!showHomeLogo || title is CamVoteLogo) {
      return title;
    }

    final destination = _resolveHomeRoute(context, ref);
    return Row(
      children: [
        _HomeLogoButton(onTap: () => context.go(destination)),
        const SizedBox(width: 10),
        Expanded(child: title),
      ],
    );
  }

  String _resolveHomeRoute(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider).asData?.value;
    final role = ref.watch(currentRoleProvider);
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;
    final entry = state.uri.queryParameters['entry']?.trim().toLowerCase();
    final isAdminContext =
        entry == 'admin' ||
        location == RoutePaths.adminPortal ||
        location.startsWith(RoutePaths.adminDashboard) ||
        location.startsWith(RoutePaths.adminRoleHub) ||
        (auth?.isAuthenticated == true &&
            auth?.user?.role == AppRole.admin &&
            location.startsWith(RoutePaths.publicHome));

    if (isAdminContext) {
      return kIsWeb ? RoutePaths.adminDashboard : RoutePaths.gateway;
    }

    final activeRole = auth?.user?.role ?? role;
    return switch (activeRole) {
      AppRole.voter =>
        kIsWeb
            ? RoutePaths.webPortal
            : (auth?.user?.verified == false
                  ? RoutePaths.voterPending
                  : RoutePaths.voterShell),
      AppRole.observer =>
        kIsWeb ? RoutePaths.observerDashboard : RoutePaths.gateway,
      AppRole.admin => kIsWeb ? RoutePaths.adminDashboard : RoutePaths.gateway,
      AppRole.public =>
        location == RoutePaths.webPortal
            ? RoutePaths.webPortal
            : RoutePaths.publicHome,
    };
  }
}

class _HomeLogoButton extends StatelessWidget {
  const _HomeLogoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: CamVoteLogo(size: 26),
        ),
      ),
    );
  }
}
