// lib/main.dart
//
// CamVote bootstrap entrypoint (Android / iOS / Web).
// - Initializes local storage (Hive)
// - Prepares timezone data (for local notifications scheduling)
// - Wraps the app with Riverpod ProviderScope
// - Sets up guarded error handling (useful for production hardening)
//
// Next file we will add: lib/app.dart (MaterialApp.router + theme + l10n + routing)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;


import 'core/notifications/local_notifications_service.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return true;
  };

  await LocalNotificationsService.instance.init();

  // Guard the whole app: in production, this is where we later connect crash reporting.
  runZonedGuarded(
    () => runApp(const ProviderScope(child: CamVoteApp())),
    (error, stack) {
      if (kDebugMode) {
        // In debug we print. In production we will forward to crash reporting.
        // ignore: avoid_print
        print('Uncaught error: $error');
        // ignore: avoid_print
        print(stack);
      }
    },
  );
}

Future<void> _bootstrap() async {
  // Local storage (works on mobile + web). We'll use it for:
  // - cached public results
  // - device/account policy cache
  // - draft registration steps
  // - UI preferences (theme/lang as fallback)
  await Hive.initFlutter();

  // Timezone DB needed for correct local notification scheduling.
  // Later we will set the local timezone more precisely when we wire notifications.
  tz.initializeTimeZones();
}
