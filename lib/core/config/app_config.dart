import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  // Configure these at build time using --dart-define.
  // Example:
  // flutter run --dart-define=CAMVOTE_API_BASE_URL=https://api.example.com
  static String get apiBaseUrl =>
      dotenv.env['CAMVOTE_API_BASE_URL'] ??
      const String.fromEnvironment('CAMVOTE_API_BASE_URL', defaultValue: '');

  static String get trelloKey =>
      dotenv.env['CAMVOTE_TRELLO_KEY'] ??
      const String.fromEnvironment('CAMVOTE_TRELLO_KEY', defaultValue: '');
  static String get trelloToken =>
      dotenv.env['CAMVOTE_TRELLO_TOKEN'] ??
      const String.fromEnvironment('CAMVOTE_TRELLO_TOKEN', defaultValue: '');
  static String get trelloBoardId =>
      dotenv.env['CAMVOTE_TRELLO_BOARD_ID'] ??
      const String.fromEnvironment('CAMVOTE_TRELLO_BOARD_ID', defaultValue: '');

  static String get supportEmail =>
      dotenv.env['CAMVOTE_SUPPORT_EMAIL'] ??
      const String.fromEnvironment('CAMVOTE_SUPPORT_EMAIL', defaultValue: '');
  static String get supportHotline =>
      dotenv.env['CAMVOTE_SUPPORT_HOTLINE'] ??
      const String.fromEnvironment('CAMVOTE_SUPPORT_HOTLINE', defaultValue: '');
  static String get receiptWatermarkAsset =>
      dotenv.env['CAMVOTE_RECEIPT_WATERMARK_ASSET'] ??
      const String.fromEnvironment(
        'CAMVOTE_RECEIPT_WATERMARK_ASSET',
        defaultValue: 'assets/images/cameroon_coat_of_arms.png',
      );
  static String get mapTileUrl =>
      dotenv.env['CAMVOTE_MAP_TILE_URL'] ??
      const String.fromEnvironment(
        'CAMVOTE_MAP_TILE_URL',
        defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
  static String get mapTileKey =>
      dotenv.env['CAMVOTE_MAP_TILE_KEY'] ??
      const String.fromEnvironment('CAMVOTE_MAP_TILE_KEY', defaultValue: '');
  static String get mapAttribution =>
      dotenv.env['CAMVOTE_MAP_ATTRIBUTION'] ??
      const String.fromEnvironment(
        'CAMVOTE_MAP_ATTRIBUTION',
        defaultValue: '© OpenStreetMap contributors',
      );
  static String get playStoreUrl =>
      dotenv.env['CAMVOTE_PLAY_STORE_URL'] ??
      const String.fromEnvironment('CAMVOTE_PLAY_STORE_URL', defaultValue: '');
  static String get appStoreUrl =>
      dotenv.env['CAMVOTE_APP_STORE_URL'] ??
      const String.fromEnvironment('CAMVOTE_APP_STORE_URL', defaultValue: '');
  static String get androidDeepLink =>
      dotenv.env['CAMVOTE_ANDROID_DEEP_LINK'] ??
      const String.fromEnvironment(
        'CAMVOTE_ANDROID_DEEP_LINK',
        defaultValue: '',
      );
  static String get iosDeepLink =>
      dotenv.env['CAMVOTE_IOS_DEEP_LINK'] ??
      const String.fromEnvironment('CAMVOTE_IOS_DEEP_LINK', defaultValue: '');
  static String get mobileFeaturesUrl =>
      dotenv.env['CAMVOTE_MOBILE_FEATURES_URL'] ??
      const String.fromEnvironment(
        'CAMVOTE_MOBILE_FEATURES_URL',
        defaultValue: '/mobile/',
      );
  static bool get iosAppLive => _parseBool(
    dotenv.env['CAMVOTE_IOS_APP_LIVE'] ??
        const String.fromEnvironment(
          'CAMVOTE_IOS_APP_LIVE',
          defaultValue: 'false',
        ),
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
  static bool get hasStoreLinks =>
      playStoreUrl.trim().isNotEmpty || appStoreUrl.trim().isNotEmpty;
  static bool get hasDeepLinks =>
      androidDeepLink.trim().isNotEmpty || iosDeepLink.trim().isNotEmpty;
  static bool get hasMobileFeaturesLink =>
      mobileFeaturesUrl.trim().isNotEmpty;

  static bool _parseBool(String raw) {
    final normalized = raw.trim().toLowerCase();
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'on';
  }
}
