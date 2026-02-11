import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'cam_motion.dart';

/// Supported page transition styles.
/// We avoid deprecated APIs and keep transitions consistent cross-platform.
enum CamRouteTransition { fadeThrough, fadeSlide, scaleFade, none }

class CamRouteTransitions {
  const CamRouteTransitions._();

  /// Wrap any screen into a CustomTransitionPage for GoRouter.
  /// Use this inside GoRoute.pageBuilder.
  static Page<T> page<T>({
    required GoRouterState state,
    required Widget child,
    CamRouteTransition transition = CamRouteTransition.fadeThrough,
    Duration? duration,
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

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return CupertinoPage<T>(key: state.pageKey, child: child);
    }

    final d = duration ?? CamMotion.medium;

    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: transition == CamRouteTransition.none
          ? Duration.zero
          : d,
      reverseTransitionDuration: transition == CamRouteTransition.none
          ? Duration.zero
          : d,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case CamRouteTransition.none:
            return child;

          case CamRouteTransition.fadeSlide:
            return _fadeSlide(animation, child);

          case CamRouteTransition.scaleFade:
            return _scaleFade(animation, child);

          case CamRouteTransition.fadeThrough:
            return _fadeThrough(animation, secondaryAnimation, child);
        }
      },
    );
  }

  static Widget _fadeSlide(Animation<double> animation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: CamMotion.emphasized,
    );
    final offsetTween = Tween<Offset>(
      begin: const Offset(0, CamMotion.slideDistance),
      end: Offset.zero,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: offsetTween.animate(curved),
        child: child,
      ),
    );
  }

  static Widget _scaleFade(Animation<double> animation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: CamMotion.emphasized,
    );
    final scaleTween = Tween<double>(begin: 0.985, end: 1.0);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: scaleTween.animate(curved), child: child),
    );
  }

  /// “Fade-through” inspired transition:
  /// - outgoing page fades slightly (using secondaryAnimation)
  /// - incoming page fades + scales in gently
  static Widget _fadeThrough(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = CurvedAnimation(
      parent: animation,
      curve: CamMotion.emphasized,
    );

    // Incoming: fade + slight scale up
    final scaleTween = Tween<double>(begin: 0.98, end: 1.0);

    // Outgoing: reduce emphasis quickly (secondaryAnimation runs when popping)
    final outgoingFade = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: incoming,
      child: ScaleTransition(
        scale: scaleTween.animate(incoming),
        child: FadeTransition(opacity: outgoingFade, child: child),
      ),
    );
  }
}
