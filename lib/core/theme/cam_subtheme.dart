import 'package:flutter/material.dart';

import 'role_theme.dart';

@immutable
class CamSubtheme extends ThemeExtension<CamSubtheme> {
  final Color roleAccent;
  final Color roleAccentSoft;
  final Color info;
  final Color onInfo;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color surfaceElevated;
  final Color surfaceMuted;
  final Color borderStrong;
  final LinearGradient heroGradient;

  const CamSubtheme({
    required this.roleAccent,
    required this.roleAccentSoft,
    required this.info,
    required this.onInfo,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.surfaceElevated,
    required this.surfaceMuted,
    required this.borderStrong,
    required this.heroGradient,
  });

  factory CamSubtheme.from({
    required ColorScheme scheme,
    required AppRole role,
    required bool isDark,
  }) {
    final accent = RoleTheme.accentFor(role);
    final accentSoft = Color.alphaBlend(
      accent.withAlpha(isDark ? 70 : 44),
      scheme.surface,
    );
    final info = Color.alphaBlend(
      scheme.primary.withAlpha(isDark ? 95 : 150),
      scheme.surface,
    );
    final warning = Color.alphaBlend(
      scheme.secondary.withAlpha(isDark ? 90 : 140),
      scheme.surface,
    );
    final successBase = isDark
        ? const Color(0xFF4FD18C)
        : const Color(0xFF0E7A43);
    final success = Color.alphaBlend(
      successBase.withAlpha(isDark ? 120 : 200),
      scheme.surface,
    );
    final surfaceElevated = Color.alphaBlend(
      (isDark ? Colors.white : Colors.black).withAlpha(isDark ? 12 : 8),
      scheme.surface,
    );
    final surfaceMuted = Color.alphaBlend(
      scheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 170),
      scheme.surface,
    );
    final borderStrong = Color.alphaBlend(
      scheme.outline.withAlpha(isDark ? 210 : 170),
      scheme.surface,
    );

    return CamSubtheme(
      roleAccent: accent,
      roleAccentSoft: accentSoft,
      info: info,
      onInfo: scheme.onSurface,
      success: success,
      onSuccess: isDark ? Colors.black : Colors.white,
      warning: warning,
      onWarning: scheme.onSurface,
      surfaceElevated: surfaceElevated,
      surfaceMuted: surfaceMuted,
      borderStrong: borderStrong,
      heroGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            scheme.primary.withAlpha(isDark ? 165 : 190),
            accent,
          ),
          Color.alphaBlend(
            scheme.secondary.withAlpha(isDark ? 130 : 150),
            accent,
          ),
          Color.alphaBlend(
            scheme.tertiary.withAlpha(isDark ? 125 : 140),
            accent,
          ),
        ],
      ),
    );
  }

  static CamSubtheme of(BuildContext context) {
    final ext = Theme.of(context).extension<CamSubtheme>();
    if (ext != null) return ext;
    final theme = Theme.of(context);
    return CamSubtheme.from(
      scheme: theme.colorScheme,
      role: AppRole.public,
      isDark: theme.brightness == Brightness.dark,
    );
  }

  @override
  CamSubtheme copyWith({
    Color? roleAccent,
    Color? roleAccentSoft,
    Color? info,
    Color? onInfo,
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? surfaceElevated,
    Color? surfaceMuted,
    Color? borderStrong,
    LinearGradient? heroGradient,
  }) {
    return CamSubtheme(
      roleAccent: roleAccent ?? this.roleAccent,
      roleAccentSoft: roleAccentSoft ?? this.roleAccentSoft,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      borderStrong: borderStrong ?? this.borderStrong,
      heroGradient: heroGradient ?? this.heroGradient,
    );
  }

  @override
  CamSubtheme lerp(ThemeExtension<CamSubtheme>? other, double t) {
    if (other is! CamSubtheme) return this;
    return CamSubtheme(
      roleAccent: Color.lerp(roleAccent, other.roleAccent, t) ?? roleAccent,
      roleAccentSoft:
          Color.lerp(roleAccentSoft, other.roleAccentSoft, t) ?? roleAccentSoft,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
          surfaceElevated,
      surfaceMuted:
          Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      borderStrong:
          Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      heroGradient:
          LinearGradient.lerp(heroGradient, other.heroGradient, t) ??
          heroGradient,
    );
  }
}
