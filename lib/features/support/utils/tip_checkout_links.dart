enum TipCheckoutProvider { tapTapSend, remitly }

extension TipCheckoutProviderX on TipCheckoutProvider {
  String get apiValue => switch (this) {
    TipCheckoutProvider.tapTapSend => 'taptap_send',
    TipCheckoutProvider.remitly => 'remitly',
  };

  String get checkoutHost => switch (this) {
    TipCheckoutProvider.tapTapSend => 'www.taptapsend.com',
    TipCheckoutProvider.remitly => 'www.remitly.com',
  };

  String get deepLinkScheme => switch (this) {
    TipCheckoutProvider.tapTapSend => 'taptapsend',
    TipCheckoutProvider.remitly => 'remitly',
  };
}

TipCheckoutProvider? tipCheckoutProviderFromValue(String rawValue) {
  final normalized = rawValue.trim().toLowerCase();
  return switch (normalized) {
    'taptap_send' || 'taptapsend' || 'taptap' => TipCheckoutProvider.tapTapSend,
    'remitly' => TipCheckoutProvider.remitly,
    _ => null,
  };
}

bool isExpectedTipCheckoutUrl({
  required TipCheckoutProvider provider,
  String? url,
}) {
  final value = url?.trim().toLowerCase() ?? '';
  if (value.isEmpty) return false;
  return value.contains(provider.checkoutHost);
}

bool isExpectedTipDeepLink({
  required TipCheckoutProvider provider,
  String? url,
}) {
  final value = url?.trim().toLowerCase() ?? '';
  if (value.isEmpty) return false;
  return value.startsWith('${provider.deepLinkScheme}://') ||
      value.startsWith('${provider.deepLinkScheme}:');
}

String maybeUpgradeMaskedRecipientNumberInCheckoutUrl(
  String checkoutUrl, {
  required String fullRecipientNumber,
}) {
  if (fullRecipientNumber.trim().isEmpty) return checkoutUrl;
  final uri = Uri.tryParse(checkoutUrl.trim());
  if (uri == null) return checkoutUrl;

  final qp = Map<String, String>.from(uri.queryParameters);
  final recipient = qp['recipient_number']?.trim() ?? '';
  if (recipient.isEmpty || !recipient.contains('*')) return checkoutUrl;
  qp['recipient_number'] = fullRecipientNumber.trim();
  return uri.replace(queryParameters: qp).toString();
}

TipCheckoutLinks buildFallbackTipCheckoutLinks({
  required TipCheckoutProvider provider,
  required String tipId,
  required int amount,
  required String currency,
  required String recipientName,
  required String recipientNumber,
}) {
  final normalizedCurrency = currency.trim().toUpperCase();
  final normalizedRecipientName = recipientName.trim();
  final normalizedRecipientNumber = recipientNumber.trim();

  final checkoutUri = Uri(
    scheme: 'https',
    host: provider.checkoutHost,
    path: '/',
    queryParameters: <String, String>{
      'utm_source': 'camvote',
      'utm_medium': 'tip',
      'camvote_tip_id': tipId,
      if (amount > 0) 'amount': '$amount',
      if (normalizedCurrency.isNotEmpty) 'currency': normalizedCurrency,
      if (normalizedRecipientName.isNotEmpty)
        'recipient_name': normalizedRecipientName,
      if (normalizedRecipientNumber.isNotEmpty)
        'recipient_number': normalizedRecipientNumber,
      'recipient_country': 'CM',
      'recipient_network': 'orange_money',
    },
  );
  final deepLinkUri = Uri(
    scheme: provider.deepLinkScheme,
    host: 'send',
    queryParameters: <String, String>{
      'tip_id': tipId,
      if (amount > 0) 'amount': '$amount',
      if (normalizedCurrency.isNotEmpty) 'currency': normalizedCurrency,
      if (normalizedRecipientName.isNotEmpty)
        'recipient_name': normalizedRecipientName,
      if (normalizedRecipientNumber.isNotEmpty)
        'recipient_number': normalizedRecipientNumber,
    },
  );
  return TipCheckoutLinks(
    checkoutUrl: checkoutUri.toString(),
    deepLink: deepLinkUri.toString(),
  );
}

class TipCheckoutLinks {
  const TipCheckoutLinks({required this.checkoutUrl, required this.deepLink});

  final String checkoutUrl;
  final String deepLink;
}
