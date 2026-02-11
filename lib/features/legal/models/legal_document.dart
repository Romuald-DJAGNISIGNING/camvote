class LegalDocument {
  final String id;
  final String title;
  final String subtitle;
  final String? assetPath;
  final String? content;
  final String sourceUrl;
  final String sourceLabel;
  final String languageCode;

  const LegalDocument({
    required this.id,
    required this.title,
    required this.subtitle,
    this.assetPath,
    this.content,
    required this.sourceUrl,
    required this.sourceLabel,
    required this.languageCode,
  });

  bool get hasInlineContent => (content ?? '').trim().isNotEmpty;
}
