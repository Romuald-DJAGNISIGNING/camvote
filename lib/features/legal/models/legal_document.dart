class LegalDocument {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String sourceUrl;
  final String sourceLabel;
  final String languageCode;

  const LegalDocument({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.sourceUrl,
    required this.sourceLabel,
    required this.languageCode,
  });
}
