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
    final auth = ref.watch(authControllerProvider).asData?.value;
    final role = ref.watch(currentRoleProvider);
    final isVoterUnverified =
        auth?.user?.role == AppRole.voter && auth?.user?.verified == false;
    final isAdminAuthed =
        auth?.isAuthenticated == true && auth?.user?.role == AppRole.admin;
    final location = state.matchedLocation;
    final entry = state.uri.queryParameters['entry'];
    final canPop = Navigator.of(context).canPop() || router.canPop();
    final hasContextualFallback = _hasContextualFallback(
      role: role,
      location: location,
      entry: entry,
      isVoterUnverified: isVoterUnverified,
      isAdminAuthed: isAdminAuthed,
    );
    if (!alwaysVisible && !canPop && !hasContextualFallback) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => _handleBack(
        context,
        role,
        isVoterUnverified,
        isAdminAuthed,
        location,
        entry,
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  bool _hasContextualFallback({
    required AppRole role,
    required String location,
    required String? entry,
    required bool isVoterUnverified,
    required bool isAdminAuthed,
  }) {
    if (location == RoutePaths.adminDashboard) return true;
    if (location.startsWith(RoutePaths.adminDashboard) &&
        location != RoutePaths.adminDashboard) {
      return true;
    }
    if (location.startsWith(RoutePaths.observerDashboard) &&
        location != RoutePaths.observerDashboard) {
      return true;
    }
    if (location.startsWith(RoutePaths.publicHome) &&
        location != RoutePaths.publicHome) {
      return true;
    }
    if (location == RoutePaths.publicHome &&
        (entry == 'admin' || isAdminAuthed)) {
      return true;
    }
    if (location == RoutePaths.authLogin && entry == 'admin') return true;
    if (entry == 'admin') return true;
    if (isVoterUnverified && location != RoutePaths.voterPending) return true;

    return switch (role) {
      AppRole.voter => location != RoutePaths.voterShell,
      AppRole.observer => location != RoutePaths.observerDashboard,
      AppRole.admin => location != RoutePaths.adminPortal,
      AppRole.public => false,
    };
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

    if (location.startsWith(RoutePaths.observerDashboard) &&
        location != RoutePaths.observerDashboard) {
      context.go(RoutePaths.observerDashboard);
      return;
    }

    if (location.startsWith(RoutePaths.publicHome) &&
        location != RoutePaths.publicHome) {
      if (entry == 'admin' || isAdminAuthed) {
        context.go('${RoutePaths.publicHome}?entry=admin');
      } else {
        context.go(RoutePaths.publicHome);
      }
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
