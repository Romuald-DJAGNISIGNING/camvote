import 'dart:ui';

import 'package:camvote/core/l10n/app_locales.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocales', () {
    test('resolve falls back to first supported locale', () {
      expect(AppLocales.resolve(null), const Locale('en'));
      expect(AppLocales.resolve(const Locale('es')), const Locale('en'));
    });

    test('fromTag resolves language variants safely', () {
      expect(AppLocales.fromTag('fr'), const Locale('fr'));
      expect(AppLocales.fromTag('fr-CA'), const Locale('fr'));
      expect(AppLocales.fromTag('EN_us'), const Locale('en'));
      expect(AppLocales.fromTag(''), const Locale('en'));
    });

    test('resolveFromPlatform always returns a supported locale', () {
      final resolved = AppLocales.resolveFromPlatform(const Locale('fr-CA'), [
        const Locale('en'),
        const Locale('fr'),
      ]);
      expect(resolved, const Locale('fr'));
    });
  });
}
