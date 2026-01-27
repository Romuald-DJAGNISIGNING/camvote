class AppConfig {
  const AppConfig._();

  // Configure these at build time using --dart-define.
  // Example:
  // flutter run --dart-define=CAMVOTE_API_BASE_URL=https://api.example.com
  static const apiBaseUrl =
      String.fromEnvironment('CAMVOTE_API_BASE_URL', defaultValue: '');

  static const trelloKey =
      String.fromEnvironment('CAMVOTE_TRELLO_KEY', defaultValue: '');
  static const trelloToken =
      String.fromEnvironment('CAMVOTE_TRELLO_TOKEN', defaultValue: '');
  static const trelloBoardId =
      String.fromEnvironment('CAMVOTE_TRELLO_BOARD_ID', defaultValue: '');

  static const supportEmail =
      String.fromEnvironment('CAMVOTE_SUPPORT_EMAIL', defaultValue: '');
  static const supportHotline =
      String.fromEnvironment('CAMVOTE_SUPPORT_HOTLINE', defaultValue: '');
  static const receiptWatermarkAsset = String.fromEnvironment(
    'CAMVOTE_RECEIPT_WATERMARK_ASSET',
    defaultValue: 'assets/images/cameroon_coat_of_arms.png',
  );
  static const mapTileUrl = String.fromEnvironment(
    'CAMVOTE_MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
  static const mapTileKey =
      String.fromEnvironment('CAMVOTE_MAP_TILE_KEY', defaultValue: '');
  static const mapAttribution = String.fromEnvironment(
    'CAMVOTE_MAP_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  static bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
  static bool get hasTrelloConfig =>
      trelloKey.trim().isNotEmpty &&
      trelloToken.trim().isNotEmpty &&
      trelloBoardId.trim().isNotEmpty;
  static bool get hasSupportContact =>
      supportEmail.trim().isNotEmpty || supportHotline.trim().isNotEmpty;
  static bool get hasReceiptWatermarkAsset =>
      receiptWatermarkAsset.trim().isNotEmpty;
  static bool get hasMapTileKey => mapTileKey.trim().isNotEmpty;
}
