import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppRole { public, voter, observer, admin }

extension AppRoleX on AppRole {
  String get apiValue => switch (this) {
    AppRole.public => 'public',
    AppRole.voter => 'voter',
    AppRole.observer => 'observer',
    AppRole.admin => 'admin',
  };

  static AppRole? fromApi(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'public' => AppRole.public,
      'voter' => AppRole.voter,
      'observer' => AppRole.observer,
      'admin' => AppRole.admin,
      _ => null,
    };
  }
}

class CurrentRoleController extends Notifier<AppRole> {
  @override
  AppRole build() => AppRole.public;

  void setRole(AppRole role) => state = role;
}

/// Global role state synchronized from auth providers.
final currentRoleProvider = NotifierProvider<CurrentRoleController, AppRole>(
  CurrentRoleController.new,
);

class RoleTheme {
  // Cameroon-inspired base colors (premium civic-tech).
  static const camGreen = Color(0xFF007A5E);
  static const camRed = Color(0xFFCE1126);
  static const camYellow = Color(0xFFFCD116);
  static const navy = Color(0xFF0B1220);

  static Color accentFor(AppRole role) {
    return switch (role) {
      AppRole.public => camGreen,
      AppRole.voter => camYellow,
      AppRole.observer => camGreen,
      AppRole.admin => camRed,
    };
  }

  static Color secondaryFor(AppRole role) {
    return switch (role) {
      AppRole.public => camYellow,
      AppRole.voter => camGreen,
      AppRole.observer => camYellow,
      AppRole.admin => camYellow,
    };
  }
}
