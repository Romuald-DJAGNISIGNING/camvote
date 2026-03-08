import 'package:flutter/foundation.dart';

String buildSmartDownloadUrl({
  required String baseUrl,
  required String languageCode,
  required String playUrl,
  required String appUrl,
  String publicUrl = '',
  String androidDeepLink = '',
  String iosDeepLink = '',
  bool iosLive = false,
}) {
  final trimmedBase = baseUrl.trim();
  if (trimmedBase.isEmpty) {
    return playUrl.isNotEmpty ? playUrl : appUrl;
  }
  final absoluteBase = _absoluteUrl(trimmedBase);
  final uri = Uri.parse(absoluteBase);
  final params = Map<String, String>.from(uri.queryParameters);
  if (playUrl.isNotEmpty) {
    params['play'] = playUrl;
  }
  if (appUrl.isNotEmpty) {
    params['app'] = appUrl;
  }
  if (languageCode.isNotEmpty) {
    params['lang'] = languageCode;
  }
  if (publicUrl.isNotEmpty) {
    params['public'] = publicUrl;
  }
  if (androidDeepLink.isNotEmpty) {
    params['deeplink_android'] = androidDeepLink;
  }
  if (iosDeepLink.isNotEmpty) {
    params['deeplink_ios'] = iosDeepLink;
  }
  if (iosLive) {
    params['ios_live'] = '1';
  }
  params['auto'] = '1';
  return uri.replace(queryParameters: params).toString();
}

String buildAndroidDownloadExperienceUrl({
  String targetUrl = '',
  String languageCode = '',
  String publicUrl = '',
}) {
  final baseUri = Uri.parse(_absoluteUrl('/mobile/apk/index.html'));
  final params = Map<String, String>.from(baseUri.queryParameters);
  final normalizedTarget = targetUrl.trim();
  if (languageCode.trim().isNotEmpty) {
    params['lang'] = languageCode.trim().toLowerCase();
  }
  if (publicUrl.trim().isNotEmpty) {
    params['public'] = publicUrl.trim();
  }
  params['auto'] = '1';
  if (normalizedTarget.isNotEmpty &&
      !isLocalAndroidDownloadExperienceUrl(normalizedTarget)) {
    params['target'] = _absoluteUrl(normalizedTarget);
  }
  return baseUri.replace(queryParameters: params).toString();
}

bool isLocalAndroidDownloadExperienceUrl(String url) {
  return url.trim().toLowerCase().contains('/mobile/apk');
}

String _absoluteUrl(String url) {
  final uri = Uri.parse(url);
  if (uri.hasScheme) return url;
  if (kIsWeb) {
    return Uri.base.resolve(url).toString();
  }
  return url;
}
