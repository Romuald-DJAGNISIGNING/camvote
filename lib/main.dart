// lib/main.dart
//
// CamVote bootstrap entrypoint (Android / iOS / Web).
// - Initializes local storage (Hive)
// - Prepares timezone data (for local notifications scheduling)
// - Wraps the app with Riverpod ProviderScope
// - Sets up guarded error handling (useful for production hardening)
//
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/notifications/local_notifications_service.dart';
import 'core/firebase/firebase_bootstrap.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  await _bootstrap();
  // Start optional startup services in parallel, but do not block first frame.
  unawaited(_loadEnv());
  unawaited(ensureFirebaseInitialized());

  // Forward Flutter framework errors into the zone (and keep them visible in debug).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  // Catch unhandled async errors (especially important on Web).
  PlatformDispatcher.instance.onError = (error, stack) {
    Zone.current.handleUncaughtError(error, stack);
    // Return false so Flutter still reports framework errors instead of
    // silently swallowing them into a blank screen.
    return false;
  };

  if (!kIsWeb) {
    unawaited(
      LocalNotificationsService.instance.init().catchError((error, stack) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('Local notifications init skipped: $error');
          // ignore: avoid_print
          print(stack);
        }
      }),
    );
  }

  // Guard the whole app: hook for crash reporting in production builds.
  runZonedGuarded(() => runApp(const ProviderScope(child: CamVoteApp())), (
    error,
    stack,
  ) {
    if (kDebugMode) {
      // In debug we print; production can forward to crash reporting.
      // ignore: avoid_print
      print('Uncaught error: $error');
      // ignore: avoid_print
      print(stack);
    }
  });
}

Future<void> _bootstrap() async {
  if (kIsWeb) return;

  // Local storage is only needed on mobile currently.
  // Fail open instead of blocking startup if the platform store is slow.
  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 3));
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Hive init skipped: $e');
      // ignore: avoid_print
      print(st);
    }
  }

  // Timezone DB needed for correct local notification scheduling.
  // Local timezone can be set by the notification layer when required.
  try {
    tz.initializeTimeZones();
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Timezone init skipped: $e');
      // ignore: avoid_print
      print(st);
    }
  }
}

Future<void> _loadEnv() async {
  if (kIsWeb) {
    try {
      await dotenv.load(fileName: '.env.public', isOptional: true);
    } catch (_) {
      // Optional: ignore missing .env.public in CI or production.
    }
    return;
  }

  try {
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (_) {
    // Optional: ignore missing .env in CI or production.
  }

  if (dotenv.env.isEmpty) {
    try {
      await dotenv.load(fileName: '.env.public', isOptional: true);
    } catch (_) {
      // Optional: ignore missing .env.public in CI or production.
    }
  }
}
