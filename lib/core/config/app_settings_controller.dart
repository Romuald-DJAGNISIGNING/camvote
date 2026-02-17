import 'dart:async';

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

// Session-only gate used to prevent web redirect races right after onboarding
// completion. Persisted onboarding state still remains the source of truth.
final onboardingSessionBypassProvider =
    NotifierProvider<OnboardingSessionBypassController, bool>(
      OnboardingSessionBypassController.new,
    );

class OnboardingSessionBypassController extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() => state = true;
}

class AppSettingsController extends AsyncNotifier<AppSettingsState> {
  static const _kTheme = 'settings.themeMode';
  static const _kThemeStyle = 'settings.themeStyle';
  static const _kLocale = 'settings.locale';
  static const _kOnboarding = 'settings.onboardingSeen';
  static const _kOnboardingVersion = 'settings.onboardingSeenVersion';
  static const _currentOnboardingVersion = 20260211;
  static const Duration _prefsTimeout = Duration(seconds: 2);
  static const AppSettingsState _fallback = AppSettingsState(
    themeMode: ThemeMode.system,
    themeStyle: AppThemeStyle.classic,
    locale: Locale('en'),
    hasSeenOnboarding: false,
  );
  static const Set<String> _allowedThemeStyleIds = {
    'classic',
    'cameroon',
    'geek',
    'fruity',
    'pro',
    'magic',
    'fun',
  };

  SharedPreferences? _prefs;

  @override
  Future<AppSettingsState> build() async {
    final prefs = await _ensurePrefs();
    if (prefs == null) {
      return _fallback;
    }

    var themeRaw = prefs.getString(_kTheme) ?? 'system';
    var themeStyleRaw = prefs.getString(_kThemeStyle) ?? 'classic';
    final localeRaw = prefs.getString(_kLocale) ?? 'en';
    final hasSeenOnboardingLegacy = prefs.getBool(_kOnboarding) ?? false;
    final seenOnboardingVersion = prefs.getInt(_kOnboardingVersion);

    var needsWriteBack = false;
    if (themeRaw != 'light' && themeRaw != 'dark' && themeRaw != 'system') {
      themeRaw = 'system';
      needsWriteBack = true;
    }
    if (!_allowedThemeStyleIds.contains(themeStyleRaw)) {
      themeStyleRaw = 'classic';
      needsWriteBack = true;
    }

    final hasSeenOnboarding =
        seenOnboardingVersion == _currentOnboardingVersion;
    final optimisticOnboardingSeen = state.maybeWhen(
      data: (value) => value.hasSeenOnboarding,
      orElse: () => false,
    );
    final effectiveOnboardingSeen =
        hasSeenOnboarding || optimisticOnboardingSeen;
    final shouldMigrateLegacyOnboarding =
        seenOnboardingVersion == null && hasSeenOnboardingLegacy;
    if (shouldMigrateLegacyOnboarding) {
      needsWriteBack = true;
    }

    final themeMode = switch (themeRaw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final locale = Locale(localeRaw);
    final themeStyle = AppThemeStyleX.fromId(themeStyleRaw);

    final resolved = AppSettingsState(
      themeMode: themeMode,
      themeStyle: themeStyle,
      locale: locale,
      hasSeenOnboarding: effectiveOnboardingSeen,
    );

    if (needsWriteBack) {
      // Normalize corrupted/legacy values so future startups stay stable.
      unawaited(_setString(_kTheme, themeRaw));
      unawaited(_setString(_kThemeStyle, themeStyleRaw));
      if (shouldMigrateLegacyOnboarding) {
        unawaited(_setInt(_kOnboardingVersion, _currentOnboardingVersion));
      }
    }

    return resolved;
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
    final current = state.value ?? _fallback;

    state = AsyncValue.data(current.copyWith(hasSeenOnboarding: seen));
    await _setBool(_kOnboarding, seen);
    if (seen) {
      await _setInt(_kOnboardingVersion, _currentOnboardingVersion);
      return;
    }
    await _removeKey(_kOnboardingVersion);
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

  Future<void> _setInt(String key, int value) async {
    final prefs = await _ensurePrefs();
    if (prefs == null) return;
    try {
      await prefs.setInt(key, value);
    } catch (_) {
      // Fail open: the in-memory state is already updated.
    }
  }

  Future<void> _removeKey(String key) async {
    final prefs = await _ensurePrefs();
    if (prefs == null) return;
    try {
      await prefs.remove(key);
    } catch (_) {
      // Fail open: the in-memory state is already updated.
    }
  }
}
