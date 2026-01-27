import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme_style.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final AppThemeStyle themeStyle;
  final Locale locale;
  final bool hasSeenOnboarding;

  const AppSettingsState({
    required this.themeMode,
    required this.themeStyle,
    required this.locale,
    required this.hasSeenOnboarding,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    AppThemeStyle? themeStyle,
    Locale? locale,
    bool? hasSeenOnboarding,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      themeStyle: themeStyle ?? this.themeStyle,
      locale: locale ?? this.locale,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettingsState>(
  AppSettingsController.new,
);

class AppSettingsController extends AsyncNotifier<AppSettingsState> {
  static const _kTheme = 'settings.themeMode';
  static const _kThemeStyle = 'settings.themeStyle';
  static const _kLocale = 'settings.locale';
  static const _kOnboarding = 'settings.onboardingSeen';

  late SharedPreferences _prefs;

  @override
  Future<AppSettingsState> build() async {
    _prefs = await SharedPreferences.getInstance();

    final themeRaw = _prefs.getString(_kTheme) ?? 'system';
    final themeStyleRaw = _prefs.getString(_kThemeStyle) ?? 'classic';
    final localeRaw = _prefs.getString(_kLocale) ?? 'en';
    final hasSeenOnboarding = _prefs.getBool(_kOnboarding) ?? false;

    final themeMode = switch (themeRaw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final locale = Locale(localeRaw);
    final themeStyle = AppThemeStyleX.fromId(themeStyleRaw);

    return AppSettingsState(
      themeMode: themeMode,
      themeStyle: themeStyle,
      locale: locale,
      hasSeenOnboarding: hasSeenOnboarding,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(themeMode: mode));

    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await _prefs.setString(_kTheme, raw);
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(themeStyle: style));
    await _prefs.setString(_kThemeStyle, style.id);
  }

  Future<void> setLocale(Locale locale) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(locale: locale));
    await _prefs.setString(_kLocale, locale.languageCode);
  }

  Future<void> setOnboardingSeen(bool seen) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(hasSeenOnboarding: seen));
    await _prefs.setBool(_kOnboarding, seen);
  }
}
