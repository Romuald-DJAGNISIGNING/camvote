import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';
import '../../theme/role_theme.dart';
import '../../../features/auth/providers/auth_providers.dart';

class AppBackButton extends ConsumerWidget {
  const AppBackButton({super.key, this.alwaysVisible = true});

  final bool alwaysVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final state = GoRouterState.of(context);
    final canPop = Navigator.of(context).canPop() || router.canPop();
    if (!canPop && !alwaysVisible) return const SizedBox.shrink();

    final auth = ref.watch(authControllerProvider).asData?.value;
    final role = ref.watch(currentRoleProvider);
    final isVoterUnverified =
        auth?.user?.role == AppRole.voter && auth?.user?.verified == false;
    final isAdminAuthed =
        auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => _handleBack(
        context,
        role,
        isVoterUnverified,
        isAdminAuthed,
        state.matchedLocation,
        state.uri.queryParameters['entry'],
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  void _handleBack(
    BuildContext context,
    AppRole role,
    bool isVoterUnverified,
    bool isAdminAuthed,
    String location,
    String? entry,
  ) {
    if (location == RoutePaths.adminDashboard) {
      context.go(RoutePaths.adminPortal);
      return;
    }

    if (location == RoutePaths.publicHome && entry == 'admin') {
      context.go(RoutePaths.adminDashboard);
      return;
    }

    if (location.startsWith(RoutePaths.adminDashboard) &&
        location != RoutePaths.adminDashboard) {
      context.go(RoutePaths.adminDashboard);
      return;
    }

    if (location == RoutePaths.authLogin && entry == 'admin') {
      context.go(RoutePaths.adminPortal);
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    final router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
      return;
    }

    if (entry == 'admin' && location.startsWith(RoutePaths.publicHome)) {
      context.go(RoutePaths.adminDashboard);
      return;
    }

    if (entry == 'admin') {
      context.go(RoutePaths.adminPortal);
      return;
    }

    if (isAdminAuthed && location.startsWith(RoutePaths.publicHome)) {
      context.go(RoutePaths.adminDashboard);
      return;
    }

    final fallback = isVoterUnverified
        ? RoutePaths.voterPending
        : switch (role) {
            AppRole.public => RoutePaths.gateway,
            AppRole.voter => RoutePaths.voterShell,
            AppRole.observer => RoutePaths.observerDashboard,
            AppRole.admin => RoutePaths.adminPortal,
          };

    context.go(fallback);
  }
}
