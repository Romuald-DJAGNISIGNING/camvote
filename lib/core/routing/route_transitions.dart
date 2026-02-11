import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class RouteTransitions {
  static CustomTransitionPage<T> fadeSlide<T>({
    required GoRouterState state,
    required Widget child,
  }) {
    if (kIsWeb) {
      return CustomTransitionPage<T>(
        key: state.pageKey,
        child: child,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      );
    }

    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final offset = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved);

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }
}
