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
  static const Duration _prefsTimeout = Duration(seconds: 2);
  static const AppSettingsState _fallback = AppSettingsState(
    themeMode: ThemeMode.system,
    themeStyle: AppThemeStyle.classic,
    locale: Locale('en'),
    hasSeenOnboarding: false,
  );

  SharedPreferences? _prefs;

  @override
  Future<AppSettingsState> build() async {
    final prefs = await _ensurePrefs();
    if (prefs == null) {
      return _fallback;
    }

    final themeRaw = prefs.getString(_kTheme) ?? 'system';
    final themeStyleRaw = prefs.getString(_kThemeStyle) ?? 'classic';
    final localeRaw = prefs.getString(_kLocale) ?? 'en';
    final hasSeenOnboarding = prefs.getBool(_kOnboarding) ?? false;

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

    await _setString(_kTheme, raw);
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(themeStyle: style));
    await _setString(_kThemeStyle, style.id);
  }

  Future<void> setLocale(Locale locale) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(locale: locale));
    await _setString(_kLocale, locale.languageCode);
  }

  Future<void> setOnboardingSeen(bool seen) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(hasSeenOnboarding: seen));
    await _setBool(_kOnboarding, seen);
  }

  Future<SharedPreferences?> _ensurePrefs() async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance().timeout(_prefsTimeout);
      return _prefs;
    } catch (_) {
      return null;
    }
  }

  Future<void> _setString(String key, String value) async {
    final prefs = await _ensurePrefs();
    if (prefs == null) return;
    try {
      await prefs.setString(key, value);
    } catch (_) {
      // Fail open: the in-memory state is already updated.
    }
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await _ensurePrefs();
    if (prefs == null) return;
    try {
      await prefs.setBool(key, value);
    } catch (_) {
      // Fail open: the in-memory state is already updated.
    }
  }
}
