import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/route_paths.dart';

/// Enables an iOS-like swipe-to-go-back gesture on all mobile platforms.
/// Only triggers when the drag starts near the left edge to avoid conflicts.
class BackSwipe extends StatefulWidget {
  final Widget child;
  const BackSwipe({super.key, required this.child});

  @override
  State<BackSwipe> createState() => _BackSwipeState();
}

class _BackSwipeState extends State<BackSwipe> {
  static const double _edgeThreshold = 24;
  static const double _dragDistance = 70;
  static const double _velocityThreshold = 800;

  Offset? _start;
  bool _eligible = false;

  bool get _enabled {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void _reset() {
    _start = null;
    _eligible = false;
  }

  void _maybePop() {
    final router = GoRouter.of(context);
    final nav = Navigator.of(context);
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;
    final entry = state.uri.queryParameters['entry'];

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

    if (nav.canPop()) {
      nav.pop();
      return;
    }

    if (!router.canPop()) return;
    if (location == RoutePaths.gateway) return;
    if (location == RoutePaths.publicHome) {
      context.go(RoutePaths.gateway);
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        _start = details.globalPosition;
        _eligible = _start!.dx <= _edgeThreshold;
      },
      onHorizontalDragUpdate: (details) {
        if (!_eligible || _start == null) return;
        final delta = details.globalPosition.dx - _start!.dx;
        if (delta > _dragDistance) {
          _reset();
          _maybePop();
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_eligible || _start == null) return;
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > _velocityThreshold) {
          _maybePop();
        }
        _reset();
      },
      onHorizontalDragCancel: _reset,
      child: widget.child,
    );
  }
}
