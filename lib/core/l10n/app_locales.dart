import 'dart:ui';

class AppLocales {
  static const supported = <Locale>[Locale('en'), Locale('fr')];

  static bool isSupported(Locale locale) {
    final code = _baseLanguageCode(locale.languageCode);
    return supported.any((item) => item.languageCode == code);
  }

  static Locale resolve(Locale? locale) {
    if (locale == null) return supported.first;
    final code = _baseLanguageCode(locale.languageCode);
    for (final item in supported) {
      if (item.languageCode == code) {
        return item;
      }
    }
    return supported.first;
  }

  static Locale fromTag(String? raw) {
    final normalized = _baseLanguageCode(raw);
    if (normalized.isEmpty) return supported.first;
    return resolve(Locale(normalized));
  }

  static Locale resolveFromPlatform(
    Locale? locale,
    Iterable<Locale> frameworkSupportedLocales,
  ) {
    final preferred = resolve(locale);
    for (final candidate in frameworkSupportedLocales) {
      if (candidate.languageCode == preferred.languageCode) {
        return candidate;
      }
    }
    if (frameworkSupportedLocales.isNotEmpty) {
      return frameworkSupportedLocales.first;
    }
    return supported.first;
  }

  static String _baseLanguageCode(String? value) {
    final normalized = (value ?? '').trim().toLowerCase().replaceAll('-', '_');
    if (normalized.isEmpty) return '';
    return normalized.split('_').first;
  }
}
