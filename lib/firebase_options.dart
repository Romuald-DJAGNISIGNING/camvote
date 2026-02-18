// File generated manually because flutterfire configure timed out in this env.
// Do not edit unless you update Firebase app credentials.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static String _fromDefines(String key) {
    return switch (key) {
      'CAMVOTE_FIREBASE_WEB_API_KEY' => const String.fromEnvironment(
        'CAMVOTE_FIREBASE_WEB_API_KEY',
      ),
      'CAMVOTE_FIREBASE_ANDROID_API_KEY' => const String.fromEnvironment(
        'CAMVOTE_FIREBASE_ANDROID_API_KEY',
      ),
      'CAMVOTE_FIREBASE_IOS_API_KEY' => const String.fromEnvironment(
        'CAMVOTE_FIREBASE_IOS_API_KEY',
      ),
      _ => '',
    };
  }

  static String _read(String key) {
    final fromDefine = _fromDefines(key).trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    try {
      final fromEnv = dotenv.env[key]?.trim() ?? '';
      if (fromEnv.isNotEmpty) return fromEnv;
    } catch (_) {
      // .env may not be loaded in tests/CI; fall through to empty.
    }
    return '';
  }

  static bool get hasWebApiKey =>
      _read('CAMVOTE_FIREBASE_WEB_API_KEY').trim().isNotEmpty;

  static bool get hasAndroidApiKey =>
      _read('CAMVOTE_FIREBASE_ANDROID_API_KEY').trim().isNotEmpty;

  static bool get hasIosApiKey =>
      _read('CAMVOTE_FIREBASE_IOS_API_KEY').trim().isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _read('CAMVOTE_FIREBASE_WEB_API_KEY'),
    appId: '1:543751728187:web:f657cc6a945bb09b6ac01e',
    messagingSenderId: '543751728187',
    projectId: 'camvote--backend',
    authDomain: 'camvote--backend.firebaseapp.com',
    storageBucket: 'camvote--backend.firebasestorage.app',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _read('CAMVOTE_FIREBASE_ANDROID_API_KEY'),
    appId: '1:543751728187:android:7ba5af0d93212cc26ac01e',
    messagingSenderId: '543751728187',
    projectId: 'camvote--backend',
    storageBucket: 'camvote--backend.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _read('CAMVOTE_FIREBASE_IOS_API_KEY'),
    appId: '1:543751728187:ios:46947c86fcd4026f6ac01e',
    messagingSenderId: '543751728187',
    projectId: 'camvote--backend',
    storageBucket: 'camvote--backend.firebasestorage.app',
    iosBundleId: 'com.camvote.app',
  );
}
