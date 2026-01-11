import 'package:flutter/material.dart';
import 'cam_colors.dart';
import 'cam_text_styles.dart';

/// CamVote application theme
class CamTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: CamColors.green,
      primary: CamColors.green,
      secondary: CamColors.yellow,
      error: CamColors.error,
      background: CamColors.background,
      surface: CamColors.surface,
    ),

    // Scaffold
    scaffoldBackgroundColor: CamColors.background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: CamColors.green,
      foregroundColor: CamColors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: CamColors.white,
      ),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CamColors.green,
        foregroundColor: CamColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CamColors.green,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CamColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CamColors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CamColors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: CamColors.error),
      ),
      filled: true,
      fillColor: CamColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Card
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: CamColors.white,
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: CamTextStyles.h1,
      displayMedium: CamTextStyles.h2,
      displaySmall: CamTextStyles.h3,
      bodyLarge: CamTextStyles.bodyLarge,
      bodyMedium: CamTextStyles.body,
      bodySmall: CamTextStyles.bodySmall,
      labelLarge: CamTextStyles.button,
      labelMedium: CamTextStyles.label,
    ),
  );
}