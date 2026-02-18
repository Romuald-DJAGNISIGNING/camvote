import 'package:camvote/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.mapAttribution', () {
    test('normalizes common mojibake symbols', () {
      dotenv.testLoad(
        fileInput:
            'CAMVOTE_MAP_ATTRIBUTION=\u00C2\u00A9 OpenStreetMap contributors',
      );

      expect(
        AppConfig.mapAttribution,
        equals('(c) OpenStreetMap contributors'),
      );
    });

    test('keeps plain ascii attribution values untouched', () {
      dotenv.testLoad(
        fileInput: 'CAMVOTE_MAP_ATTRIBUTION=(c) OpenStreetMap contributors',
      );

      expect(
        AppConfig.mapAttribution,
        equals('(c) OpenStreetMap contributors'),
      );
    });
  });

  group('AppConfig.tipOrangeMoneyNumberPublic', () {
    test('parses truthy values', () {
      dotenv.testLoad(fileInput: 'CAMVOTE_TIP_ORANGE_MONEY_NUMBER_PUBLIC=yes');

      expect(AppConfig.tipOrangeMoneyNumberPublic, isTrue);
    });

    test('parses falsy values', () {
      dotenv.testLoad(fileInput: 'CAMVOTE_TIP_ORANGE_MONEY_NUMBER_PUBLIC=no');

      expect(AppConfig.tipOrangeMoneyNumberPublic, isFalse);
    });
  });
}
