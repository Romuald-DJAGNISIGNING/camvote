import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';

/// Central motion tokens for CamVote (durations + curves).
/// Keeps all animations consistent and premium across Android/iOS/Web.
@immutable
class CamMotion {
  const CamMotion._();

  /// Quick UI feedback (taps, small UI changes)
  static const Duration fast = Duration(milliseconds: 180);

  /// Standard page/screen transitions and component reveals
  static const Duration medium = Duration(milliseconds: 260);

  /// Longer transitions for celebratory moments / big content loads
  static const Duration slow = Duration(milliseconds: 420);

  /// Primary curve used across the app (premium feel)
  static const Curve emphasized = Curves.easeOutCubic;

  /// Standard UI curve
  static const Curve standard = Curves.easeOut;

  /// Smooth deceleration
  static const Curve decel = Curves.decelerate;

  /// Default slide distance as a fraction of the screen.
  /// Small value = elegant, not “cartoony”.
  static const double slideDistance = 0.035;
}
