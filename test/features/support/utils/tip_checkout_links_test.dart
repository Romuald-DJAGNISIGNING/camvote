import 'package:camvote/features/support/utils/tip_checkout_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tipCheckoutProviderFromValue', () {
    test('maps supported providers', () {
      expect(
        tipCheckoutProviderFromValue('taptap_send'),
        TipCheckoutProvider.tapTapSend,
      );
      expect(
        tipCheckoutProviderFromValue('TAPTAPSEND'),
        TipCheckoutProvider.tapTapSend,
      );
      expect(
        tipCheckoutProviderFromValue('remitly'),
        TipCheckoutProvider.remitly,
      );
      expect(tipCheckoutProviderFromValue('unknown'), isNull);
    });
  });

  group('buildFallbackTipCheckoutLinks', () {
    test('creates TapTap checkout and deep link with tracking params', () {
      final links = buildFallbackTipCheckoutLinks(
        provider: TipCheckoutProvider.tapTapSend,
        tipId: 'tip_42',
        amount: 15000,
        currency: 'xaf',
        recipientName: 'CamVote Support',
        recipientNumber: '+237690001122',
      );
      final checkout = Uri.parse(links.checkoutUrl);
      final deepLink = Uri.parse(links.deepLink);

      expect(checkout.host, equals('www.taptapsend.com'));
      expect(checkout.queryParameters['camvote_tip_id'], equals('tip_42'));
      expect(checkout.queryParameters['currency'], equals('XAF'));
      expect(checkout.queryParameters['recipient_country'], equals('CM'));

      expect(deepLink.scheme, equals('taptapsend'));
      expect(deepLink.queryParameters['tip_id'], equals('tip_42'));
    });

    test('creates Remitly checkout and deep link with tracking params', () {
      final links = buildFallbackTipCheckoutLinks(
        provider: TipCheckoutProvider.remitly,
        tipId: 'tip_99',
        amount: 3400,
        currency: 'eur',
        recipientName: 'CamVote Support',
        recipientNumber: '+237699887766',
      );
      final checkout = Uri.parse(links.checkoutUrl);
      final deepLink = Uri.parse(links.deepLink);

      expect(checkout.host, equals('www.remitly.com'));
      expect(checkout.queryParameters['camvote_tip_id'], equals('tip_99'));
      expect(checkout.queryParameters['currency'], equals('EUR'));

      expect(deepLink.scheme, equals('remitly'));
      expect(deepLink.queryParameters['tip_id'], equals('tip_99'));
    });
  });

  group('maybeUpgradeMaskedRecipientNumberInCheckoutUrl', () {
    test('replaces masked recipient number when full number is available', () {
      const original =
          'https://www.remitly.com/?recipient_number=%2B23769****17&amount=2500';
      final upgraded = maybeUpgradeMaskedRecipientNumberInCheckoutUrl(
        original,
        fullRecipientNumber: '+237692418817',
      );
      final query = Uri.parse(upgraded).queryParameters;
      expect(query['recipient_number'], equals('+237692418817'));
    });

    test('keeps checkout url unchanged when recipient is already full', () {
      const original =
          'https://www.remitly.com/?recipient_number=%2B237692418817&amount=2500';
      final upgraded = maybeUpgradeMaskedRecipientNumberInCheckoutUrl(
        original,
        fullRecipientNumber: '+237692418817',
      );
      expect(upgraded, equals(original));
    });
  });
}
