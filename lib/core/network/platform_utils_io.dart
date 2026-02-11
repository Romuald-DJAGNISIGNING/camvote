import 'package:flutter/foundation.dart';

bool get isAndroidPlatform =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get isIosPlatform => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool get isWebPlatform => kIsWeb;

String get webUserAgent => '';

bool get isAndroidWeb => false;
bool get isIosWeb => false;
bool get isMobileWeb => false;
bool get isDesktopWeb => false;

void openWebRedirect(String url) {}
