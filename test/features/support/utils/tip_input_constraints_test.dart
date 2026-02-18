import 'package:camvote/features/support/utils/tip_input_constraints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tip input constraints', () {
    test('accepts supported currencies and normalizes case', () {
      expect(normalizeTipCurrency('xaf'), equals('XAF'));
      expect(normalizeTipCurrency(' USD '), equals('USD'));
      expect(normalizeTipCurrency(''), equals('XAF'));
    });

    test('rejects unsupported currencies', () {
      expect(() => normalizeTipCurrency('JPY'), throwsA(isA<ArgumentError>()));
    });

    test('amount range checker respects limits', () {
      expect(isTipAmountInRange(tipMinAmount - 1), isFalse);
      expect(isTipAmountInRange(tipMinAmount), isTrue);
      expect(isTipAmountInRange(tipMaxAmount), isTrue);
      expect(isTipAmountInRange(tipMaxAmount + 1), isFalse);
    });

    test('name sanitizer applies anonymous/public defaults', () {
      expect(
        sanitizeTipName('', anonymous: true),
        equals('Anonymous supporter'),
      );
      expect(sanitizeTipName('', anonymous: false), equals('Supporter'));
      expect(
        sanitizeTipName('  Jane  Doe  ', anonymous: false),
        equals('Jane Doe'),
      );
    });

    test('email validation and normalization work together', () {
      final email = sanitizeTipEmail('  PERSON@EXAMPLE.COM ');
      expect(email, equals('person@example.com'));
      expect(isValidTipEmail(email), isTrue);
      expect(isValidTipEmail('bad-email'), isFalse);
    });

    test('attachment sanitization deduplicates and enforces https', () {
      final urls = sanitizeTipAttachmentUrls([
        'https://example.com/a.png',
        'https://example.com/a.png',
        'https://example.com/b.png',
      ]);
      expect(urls, hasLength(2));
      expect(
        () => sanitizeTipAttachmentUrls(['http://example.com/insecure.png']),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
