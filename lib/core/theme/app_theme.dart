import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'role_theme.dart';
import 'app_theme_style.dart';
import '../branding/brand_palette.dart';

class AppThemePack {
  final ThemeData light;
  final ThemeData dark;

  const AppThemePack({required this.light, required this.dark});
}

class AppTheme {
  static AppThemePack build({
    required AppRole role,
    required ThemeMode mode,
    required AppThemeStyle style,
  }) {
    final flavor = _flavor(style, role);
    final lightScheme = _lightScheme(flavor);
    final darkScheme = _darkScheme(flavor);

    ThemeData base(ColorScheme scheme, bool isDark) => ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      textTheme: _textTheme(isDark: isDark),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: kIsWeb ? Colors.transparent : scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: _textTheme(
          isDark: isDark,
        ).titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            _textTheme(isDark: isDark).labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(scheme.primary),
          foregroundColor: WidgetStateProperty.all(scheme.onPrimary),
          textStyle: WidgetStateProperty.all(
            _textTheme(isDark: isDark).labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: scheme.outlineVariant.withAlpha(140)),
          ),
          textStyle: WidgetStateProperty.all(
            _textTheme(isDark: isDark).labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            _textTheme(
              isDark: isDark,
            ).labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withAlpha(isDark ? 90 : 160),
        labelStyle: _textTheme(
          isDark: isDark,
        ).labelLarge?.copyWith(color: scheme.onSurface.withAlpha(190)),
        floatingLabelStyle: _textTheme(isDark: isDark).labelLarge?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface.withAlpha(230),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: _textTheme(
          isDark: isDark,
        ).labelMedium?.copyWith(color: scheme.onInverseSurface),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withAlpha(40),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(scheme.primary),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withAlpha(120)
              : scheme.outlineVariant.withAlpha(120),
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? scheme.primary : null,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: _textTheme(
          isDark: isDark,
        ).titleLarge?.copyWith(fontWeight: FontWeight.w900),
        contentTextStyle: _textTheme(isDark: isDark).bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withAlpha(90),
        thickness: 0.9,
        space: 16,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest.withAlpha(isDark ? 110 : 230),
        elevation: isDark ? 0 : 0.6,
        shadowColor: scheme.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withAlpha(70)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface.withAlpha(190),
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.standard,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: _textTheme(isDark: isDark).labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: BorderSide(color: scheme.outlineVariant.withAlpha(120)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          _textTheme(
            isDark: isDark,
          ).labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        indicatorColor: scheme.primaryContainer,
        backgroundColor: scheme.surface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return AppThemePack(
      light: base(lightScheme, false),
      dark: base(darkScheme, true),
    );
  }

  static TextTheme _textTheme({required bool isDark}) {
    final base = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final display = GoogleFonts.spaceGroteskTextTheme(base);
    final body = GoogleFonts.manropeTextTheme(base);

    return display.copyWith(
      displayLarge: display.displayLarge?.copyWith(fontWeight: FontWeight.w900),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: display.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: display.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: body.bodyLarge,
      bodyMedium: body.bodyMedium,
      bodySmall: body.bodySmall,
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: body.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      labelSmall: body.labelSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  static ColorScheme _lightScheme(_ThemeFlavor flavor) {
    return ColorScheme(
      brightness: Brightness.light,
      primary: flavor.primary,
      onPrimary: Colors.white,
      primaryContainer: flavor.primary.withAlpha(28),
      onPrimaryContainer: BrandPalette.ink,
      secondary: flavor.secondary,
      onSecondary: Colors.white,
      secondaryContainer: flavor.secondary.withAlpha(25),
      onSecondaryContainer: BrandPalette.ink,
      tertiary: flavor.tertiary,
      onTertiary: BrandPalette.ink,
      tertiaryContainer: flavor.tertiary.withAlpha(26),
      onTertiaryContainer: BrandPalette.ink,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: flavor.lightSurface,
      onSurface: BrandPalette.ink,
      surfaceContainerHighest: flavor.lightSurfaceVariant,
      onSurfaceVariant: BrandPalette.inkSoft,
      outline: BrandPalette.inkSoft.withAlpha(60),
      outlineVariant: BrandPalette.inkSoft.withAlpha(30),
      shadow: Colors.black.withAlpha(25),
      scrim: Colors.black.withAlpha(90),
      inverseSurface: BrandPalette.inkSoft,
      onInverseSurface: BrandPalette.paper,
      inversePrimary: flavor.primary.withAlpha(200),
    );
  }

  static ColorScheme _darkScheme(_ThemeFlavor flavor) {
    return ColorScheme(
      brightness: Brightness.dark,
      primary: flavor.primary.withAlpha(220),
      onPrimary: Colors.black,
      primaryContainer: flavor.primary.withAlpha(60),
      onPrimaryContainer: Colors.white,
      secondary: flavor.secondary.withAlpha(220),
      onSecondary: Colors.black,
      secondaryContainer: flavor.secondary.withAlpha(70),
      onSecondaryContainer: Colors.white,
      tertiary: flavor.tertiary.withAlpha(230),
      onTertiary: Colors.black,
      tertiaryContainer: flavor.tertiary.withAlpha(80),
      onTertiaryContainer: Colors.white,
      error: const Color(0xFFF2B8B5),
      onError: Colors.black,
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: flavor.darkSurface,
      onSurface: const Color(0xFFF3F3F3),
      surfaceContainerHighest: flavor.darkSurfaceVariant,
      onSurfaceVariant: const Color(0xFFE1E1E1),
      outline: Colors.white.withAlpha(50),
      outlineVariant: Colors.white.withAlpha(25),
      shadow: Colors.black.withAlpha(130),
      scrim: Colors.black.withAlpha(160),
      inverseSurface: const Color(0xFFE7E3D7),
      onInverseSurface: const Color(0xFF181B20),
      inversePrimary: flavor.primary.withAlpha(200),
    );
  }

  static _ThemeFlavor _flavor(AppThemeStyle style, AppRole role) {
    switch (style) {
      case AppThemeStyle.cameroon:
        return const _ThemeFlavor(
          primary: Color(0xFF00873E),
          secondary: Color(0xFFCE1126),
          tertiary: Color(0xFFFCD116),
          lightSurface: Color(0xFFFFF9F1),
          lightSurfaceVariant: Color(0xFFFFF2E1),
          darkSurface: Color(0xFF0B0F12),
          darkSurfaceVariant: Color(0xFF151B20),
        );
      case AppThemeStyle.geek:
        return const _ThemeFlavor(
          primary: Color(0xFF00D1FF),
          secondary: Color(0xFF7C5CFF),
          tertiary: Color(0xFF00FF87),
          lightSurface: Color(0xFFF5FAFF),
          lightSurfaceVariant: Color(0xFFE9F2FF),
          darkSurface: Color(0xFF0A0F16),
          darkSurfaceVariant: Color(0xFF111923),
        );
      case AppThemeStyle.fruity:
        return const _ThemeFlavor(
          primary: Color(0xFFFF6B6B),
          secondary: Color(0xFFFFD93D),
          tertiary: Color(0xFF6BCB77),
          lightSurface: Color(0xFFFFF7F0),
          lightSurfaceVariant: Color(0xFFFFEBDD),
          darkSurface: Color(0xFF14100E),
          darkSurfaceVariant: Color(0xFF1C1614),
        );
      case AppThemeStyle.pro:
        return const _ThemeFlavor(
          primary: Color(0xFF1F3A5F),
          secondary: Color(0xFFC9A227),
          tertiary: Color(0xFF5B7B9A),
          lightSurface: Color(0xFFF6F7FA),
          lightSurfaceVariant: Color(0xFFEAEFF5),
          darkSurface: Color(0xFF0E1218),
          darkSurfaceVariant: Color(0xFF151B22),
        );
      case AppThemeStyle.magic:
        return const _ThemeFlavor(
          primary: Color(0xFF1B5E83),
          secondary: Color(0xFF00BFA6),
          tertiary: Color(0xFFF6B73C),
          lightSurface: Color(0xFFF4F7FB),
          lightSurfaceVariant: Color(0xFFE7F0F7),
          darkSurface: Color(0xFF0B131A),
          darkSurfaceVariant: Color(0xFF111B23),
        );
      case AppThemeStyle.fun:
        return const _ThemeFlavor(
          primary: Color(0xFFFF6F61),
          secondary: Color(0xFF2EC4B6),
          tertiary: Color(0xFFFFC857),
          lightSurface: Color(0xFFFFF7F2),
          lightSurfaceVariant: Color(0xFFFFEDE6),
          darkSurface: Color(0xFF160F0D),
          darkSurfaceVariant: Color(0xFF1F1613),
        );
      case AppThemeStyle.classic:
        return _ThemeFlavor(
          primary: RoleTheme.accentFor(role),
          secondary: BrandPalette.ocean,
          tertiary: BrandPalette.sunrise,
          lightSurface: BrandPalette.paper,
          lightSurfaceVariant: BrandPalette.mist,
          darkSurface: const Color(0xFF0E1116),
          darkSurfaceVariant: const Color(0xFF171B22),
        );
    }
  }
}

class _ThemeFlavor {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color lightSurface;
  final Color lightSurfaceVariant;
  final Color darkSurface;
  final Color darkSurfaceVariant;

  const _ThemeFlavor({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.lightSurface,
    required this.lightSurfaceVariant,
    required this.darkSurface,
    required this.darkSurfaceVariant,
  });
}
