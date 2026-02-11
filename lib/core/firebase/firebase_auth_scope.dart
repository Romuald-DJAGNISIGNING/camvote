import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const webAdminFirebaseAppName = 'camvote_admin_scope';
const webGeneralFirebaseAppName = 'camvote_general_scope';

enum WebAuthScope { admin, general }

WebAuthScope resolveWebAuthScope([Uri? uri]) {
  if (!kIsWeb) return WebAuthScope.general;

  final base = uri ?? Uri.base;
  String route = '/';
  Map<String, String> params = const <String, String>{};

  if (base.fragment.isNotEmpty) {
    final fragmentUri = Uri.parse(
      base.fragment.startsWith('/') ? base.fragment : '/${base.fragment}',
    );
    route = fragmentUri.path.isEmpty ? '/' : fragmentUri.path;
    params = fragmentUri.queryParameters;
  } else {
    route = base.path.isEmpty ? '/' : base.path;
    params = base.queryParameters;
  }

  final role = params['role'];
  final entry = params['entry'];
  final isAdminEntry =
      route.startsWith('/backoffice') ||
      route.startsWith('/admin') ||
      entry == 'admin' ||
      role == 'admin';

  return isAdminEntry ? WebAuthScope.admin : WebAuthScope.general;
}

FirebaseApp resolveFirebaseAppForScope([WebAuthScope? scope]) {
  final targetScope = kIsWeb ? (scope ?? resolveWebAuthScope()) : null;
  final appName = targetScope == WebAuthScope.admin
      ? webAdminFirebaseAppName
      : webGeneralFirebaseAppName;

  if (!kIsWeb) {
    return Firebase.app();
  }

  try {
    return Firebase.app(appName);
  } catch (_) {
    return Firebase.app();
  }
}
