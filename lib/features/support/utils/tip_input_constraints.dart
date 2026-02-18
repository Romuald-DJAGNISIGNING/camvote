const int tipMinAmount = 100;
const int tipMaxAmount = 5000000;
const int tipMaxMessageLength = 280;
const int tipMaxSenderNameLength = 80;
const int tipMaxSourceLength = 64;
const int tipMaxReferenceLength = 120;
const int tipMaxAttachments = 5;
const int tipMaxAttachmentUrlLength = 2048;

const Set<String> tipSupportedCurrencies = {'XAF', 'USD', 'EUR'};

final RegExp _tipEmailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final RegExp _tipControlCharsPattern = RegExp(r'[\u0000-\u001F\u007F]');

bool isTipAmountInRange(int amount) {
  return amount >= tipMinAmount && amount <= tipMaxAmount;
}

String normalizeTipCurrency(String rawCurrency) {
  final normalized = rawCurrency.trim().toUpperCase();
  final fallback = normalized.isEmpty ? 'XAF' : normalized;
  if (!tipSupportedCurrencies.contains(fallback)) {
    throw ArgumentError.value(
      rawCurrency,
      'rawCurrency',
      'Unsupported currency.',
    );
  }
  return fallback;
}

String sanitizeTipSource(String rawSource) {
  final compact = sanitizeTipText(
    rawSource,
    maxLength: tipMaxSourceLength,
  ).toLowerCase();
  if (compact.isEmpty) return 'camvote_app';
  final normalized = compact
      .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return normalized.isEmpty ? 'camvote_app' : normalized;
}

String sanitizeTipText(String rawText, {required int maxLength}) {
  final stripped = rawText
      .replaceAll(_tipControlCharsPattern, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (stripped.length <= maxLength) return stripped;
  return stripped.substring(0, maxLength).trim();
}

String sanitizeTipMessage(String rawMessage) {
  return sanitizeTipText(rawMessage, maxLength: tipMaxMessageLength);
}

String sanitizeTipName(String rawName, {required bool anonymous}) {
  if (anonymous) return 'Anonymous supporter';
  final cleaned = sanitizeTipText(rawName, maxLength: tipMaxSenderNameLength);
  return cleaned.isEmpty ? 'Supporter' : cleaned;
}

String sanitizeTipEmail(String rawEmail) {
  return sanitizeTipText(rawEmail, maxLength: 254).toLowerCase();
}

bool isValidTipEmail(String email) {
  final normalized = email.trim();
  if (normalized.isEmpty) return true;
  return _tipEmailPattern.hasMatch(normalized);
}

String sanitizeTipReference(String rawReference) {
  return sanitizeTipText(
    rawReference,
    maxLength: tipMaxReferenceLength,
  ).toUpperCase();
}

List<String> sanitizeTipAttachmentUrls(Iterable<String> rawUrls) {
  final result = <String>[];
  final seen = <String>{};
  for (final candidate in rawUrls) {
    final trimmed = candidate.trim();
    if (trimmed.isEmpty) continue;
    if (trimmed.length > tipMaxAttachmentUrlLength) {
      throw ArgumentError.value(
        candidate,
        'candidate',
        'Attachment URL is too long.',
      );
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.trim().isEmpty) {
      throw ArgumentError.value(
        candidate,
        'candidate',
        'Attachment URL is invalid.',
      );
    }
    final scheme = uri.scheme.toLowerCase();
    final isLocalHttp =
        scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');
    if (scheme != 'https' && !isLocalHttp) {
      throw ArgumentError.value(
        candidate,
        'candidate',
        'Attachment URL must use HTTPS.',
      );
    }
    final normalized = uri.toString();
    if (!seen.add(normalized)) continue;
    result.add(normalized);
    if (result.length > tipMaxAttachments) {
      throw ArgumentError.value(
        candidate,
        'candidate',
        'Too many attachments.',
      );
    }
  }
  return result;
}
