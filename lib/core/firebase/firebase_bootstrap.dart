import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'firebase_auth_scope.dart';

Future<void>? _firebaseInitFuture;

/// Initializes Firebase once for the whole app and reuses the same in-flight
/// future across callers to avoid duplicate-app races on startup.
Future<void> ensureFirebaseInitialized({
  Duration timeout = const Duration(seconds: 5),
}) {
  if (Firebase.apps.isNotEmpty) return Future<void>.value();
  final inFlight = _firebaseInitFuture;
  if (inFlight != null) return inFlight;

  final future = _initialize(timeout);
  _firebaseInitFuture = future;
  return future;
}

Future<void> _initialize(Duration timeout) async {
  try {
    if (!DefaultFirebaseOptions.hasRequiredApiKeys) {
      if (kDebugMode) {
        // ignore: avoid_print
        print(
          'Firebase init skipped: missing CAMVOTE_FIREBASE_*_API_KEY configuration.',
        );
      }
      return;
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(timeout);
    }

    if (kIsWeb) {
      await _ensureNamedWebApp(webAdminFirebaseAppName, timeout);
      await _ensureNamedWebApp(webGeneralFirebaseAppName, timeout);
    }
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Firebase init skipped: $e');
      // ignore: avoid_print
      print(st);
    }
  }
}

Future<void> _ensureNamedWebApp(String appName, Duration timeout) async {
  try {
    Firebase.app(appName);
    return;
  } catch (_) {
    // App does not exist yet; create it below.
  }

  await Firebase.initializeApp(
    name: appName,
    options: DefaultFirebaseOptions.currentPlatform,
  ).timeout(timeout);
}
