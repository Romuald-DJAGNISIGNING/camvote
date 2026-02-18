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
    if (kIsWeb && !DefaultFirebaseOptions.hasWebApiKey) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Firebase init skipped: missing CAMVOTE_FIREBASE_WEB_API_KEY.');
      }
      return;
    }

    if (Firebase.apps.isEmpty) {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(timeout);
      } else {
        // On Android/iOS, prefer native GoogleService config files so secrets
        // do not have to be injected into the Dart bundle.
        try {
          await Firebase.initializeApp().timeout(timeout);
        } catch (error) {
          // Fallback: allow explicit options for environments without native
          // config files (CI, local dev with stripped configs).
          final options = DefaultFirebaseOptions.currentPlatform;
          final hasKey = options.apiKey.trim().isNotEmpty;
          if (!hasKey) {
            rethrow;
          }
          await Firebase.initializeApp(options: options).timeout(timeout);
        }
      }
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
