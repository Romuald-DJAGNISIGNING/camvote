// File generated manually because flutterfire configure timed out in this env.
// Do not edit unless you update Firebase app credentials.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCstjo3EEpZgw3bUnp0AYdq4EmYP8tALMQ',
    appId: '1:543751728187:web:f657cc6a945bb09b6ac01e',
    messagingSenderId: '543751728187',
    projectId: 'camvote--backend',
    authDomain: 'camvote--backend.firebaseapp.com',
    storageBucket: 'camvote--backend.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5GUG4PvaUwsnIv56tDLp1yxQJaQghiko',
    appId: '1:543751728187:android:7ba5af0d93212cc26ac01e',
    messagingSenderId: '543751728187',
    projectId: 'camvote--backend',
    storageBucket: 'camvote--backend.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJFnBqcCYf-W1bmKA4y-jAEB1TmX1vAhE',
    appId: '1:543751728187:ios:46947c86fcd4026f6ac01e',
    messagingSenderId: '543751728187',
    projectId: 'camvote--backend',
    storageBucket: 'camvote--backend.firebasestorage.app',
    iosBundleId: 'com.camvote.app',
  );
}
