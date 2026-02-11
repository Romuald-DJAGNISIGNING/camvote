// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'package:flutter/foundation.dart';

bool get isAndroidPlatform => false;
bool get isIosPlatform => false;
bool get isWebPlatform => kIsWeb;

String get webUserAgent => html.window.navigator.userAgent.toLowerCase();

bool get isAndroidWeb => isWebPlatform && webUserAgent.contains('android');

bool get isIosWeb {
  if (!isWebPlatform) return false;
  final ua = webUserAgent;
  final isIphone = ua.contains('iphone');
  final isIpad = ua.contains('ipad') ||
      (ua.contains('macintosh') && ua.contains('mobile'));
  final isIpod = ua.contains('ipod');
  return isIphone || isIpad || isIpod;
}

bool get isMobileWeb => isAndroidWeb || isIosWeb;
bool get isDesktopWeb => isWebPlatform && !isMobileWeb;

void openWebRedirect(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return;
  html.window.location.assign(trimmed);
}
