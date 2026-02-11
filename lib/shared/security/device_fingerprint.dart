import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'hash_utils.dart';

class DeviceFingerprint {
  const DeviceFingerprint._();

  static Future<String> compute() async {
    try {
      final info = DeviceInfoPlugin();
      final payload = <String, dynamic>{};

      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        payload.addAll({
          'platform': 'web',
          'userAgent': web.userAgent,
          'vendor': web.vendor,
          'hardwareConcurrency': web.hardwareConcurrency,
          'language': web.language,
        });
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final android = await info.androidInfo;
            payload.addAll({
              'platform': 'android',
              'model': android.model,
              'brand': android.brand,
              'device': android.device,
              'manufacturer': android.manufacturer,
              'androidId': android.id,
            });
          case TargetPlatform.iOS:
            final ios = await info.iosInfo;
            payload.addAll({
              'platform': 'ios',
              'name': ios.name,
              'model': ios.model,
              'systemVersion': ios.systemVersion,
              'identifierForVendor': ios.identifierForVendor,
            });
          case TargetPlatform.macOS:
            final mac = await info.macOsInfo;
            payload.addAll({
              'platform': 'macos',
              'model': mac.model,
              'osRelease': mac.osRelease,
            });
          case TargetPlatform.windows:
            final win = await info.windowsInfo;
            payload.addAll({
              'platform': 'windows',
              'productName': win.productName,
              'deviceId': win.deviceId,
            });
          case TargetPlatform.linux:
            final linux = await info.linuxInfo;
            payload.addAll({
              'platform': 'linux',
              'machineId': linux.machineId,
              'name': linux.name,
              'version': linux.version,
            });
          case TargetPlatform.fuchsia:
            payload['platform'] = 'fuchsia';
        }
      }

      return HashUtils.sha256Hex(payload.toString());
    } catch (_) {
      return HashUtils.sha256Hex('unknown-device');
    }
  }
}
