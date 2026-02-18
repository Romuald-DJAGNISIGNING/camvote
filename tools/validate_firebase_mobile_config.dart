import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final allowMissingNativeFiles = args.contains('--allow-missing-native-files');
  final result = _runValidation(
    allowMissingNativeFiles: allowMissingNativeFiles,
  );
  if (!result.ok) {
    stderr.writeln(result.summary);
    exitCode = 1;
    return;
  }
  stdout.writeln(result.summary);
}

_ValidationResult _runValidation({required bool allowMissingNativeFiles}) {
  final errors = <String>[];
  final warnings = <String>[];
  final checks = <String>[];

  final firebaseOptionsFile = File('lib/firebase_options.dart');
  if (!firebaseOptionsFile.existsSync()) {
    return _ValidationResult(
      ok: false,
      summary:
          'Firebase config validation failed.\n- Missing lib/firebase_options.dart',
    );
  }

  final firebaseOptionsSource = firebaseOptionsFile.readAsStringSync();
  final androidOptions = _extractPlatformOptions(
    source: firebaseOptionsSource,
    platformName: 'android',
  );
  final iosOptions = _extractPlatformOptions(
    source: firebaseOptionsSource,
    platformName: 'ios',
  );

  if (androidOptions == null) {
    errors.add(
      'Unable to parse Android FirebaseOptions in firebase_options.dart',
    );
  }
  if (iosOptions == null) {
    errors.add('Unable to parse iOS FirebaseOptions in firebase_options.dart');
  }
  if (errors.isNotEmpty) {
    return _ValidationResult(
      ok: false,
      summary: _buildSummary(
        ok: false,
        checks: checks,
        warnings: warnings,
        errors: errors,
      ),
    );
  }

  checks.add(
    'Parsed Android/iOS FirebaseOptions from lib/firebase_options.dart',
  );

  final expectedProjectId = androidOptions!['projectId'] ?? '';
  final expectedStorageBucket = androidOptions['storageBucket'] ?? '';
  final expectedSenderId = androidOptions['messagingSenderId'] ?? '';
  final expectedAndroidAppId = androidOptions['appId'] ?? '';
  final expectedIosAppId = iosOptions!['appId'] ?? '';
  final expectedBundleId = iosOptions['iosBundleId'] ?? '';

  if (expectedProjectId.isEmpty ||
      expectedStorageBucket.isEmpty ||
      expectedSenderId.isEmpty ||
      expectedAndroidAppId.isEmpty ||
      expectedIosAppId.isEmpty ||
      expectedBundleId.isEmpty) {
    errors.add(
      'firebase_options.dart is missing required Android/iOS fields '
      '(projectId, storageBucket, messagingSenderId, appId, iosBundleId).',
    );
  }

  final androidGoogleServices = File('android/app/google-services.json');
  if (!androidGoogleServices.existsSync()) {
    if (!allowMissingNativeFiles) {
      errors.add('Missing android/app/google-services.json');
    } else {
      warnings.add(
        'android/app/google-services.json not found (allowed by --allow-missing-native-files).',
      );
    }
  } else {
    checks.add('Found android/app/google-services.json');
    final androidRaw = androidGoogleServices.readAsStringSync();
    try {
      final parsed = json.decode(androidRaw) as Map<String, dynamic>;
      final projectInfo =
          (parsed['project_info'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      final projectId = '${projectInfo['project_id'] ?? ''}'.trim();
      final storageBucket = '${projectInfo['storage_bucket'] ?? ''}'.trim();
      final projectNumber = '${projectInfo['project_number'] ?? ''}'.trim();

      if (projectId != expectedProjectId) {
        errors.add(
          'google-services.json project_id ($projectId) does not match '
          'firebase_options.dart ($expectedProjectId).',
        );
      }
      if (storageBucket != expectedStorageBucket) {
        errors.add(
          'google-services.json storage_bucket ($storageBucket) does not match '
          'firebase_options.dart ($expectedStorageBucket).',
        );
      }
      if (projectNumber != expectedSenderId) {
        errors.add(
          'google-services.json project_number ($projectNumber) does not match '
          'firebase_options.dart messagingSenderId ($expectedSenderId).',
        );
      }

      final clients = (parsed['client'] as List? ?? const <dynamic>[])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      final matchingClient = clients.firstWhere((client) {
        final info =
            (client['client_info'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final androidClientInfo =
            (info['android_client_info'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final packageName = '${androidClientInfo['package_name'] ?? ''}'.trim();
        return packageName == expectedBundleId;
      }, orElse: () => const <String, dynamic>{});
      if (matchingClient.isEmpty) {
        errors.add(
          'google-services.json has no client for package "$expectedBundleId".',
        );
      } else {
        final clientInfo =
            (matchingClient['client_info'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final appId = '${clientInfo['mobilesdk_app_id'] ?? ''}'.trim();
        if (appId != expectedAndroidAppId) {
          errors.add(
            'google-services.json mobilesdk_app_id ($appId) does not match '
            'firebase_options.dart Android appId ($expectedAndroidAppId).',
          );
        }
        final apiKeys =
            (matchingClient['api_key'] as List? ?? const <dynamic>[])
                .whereType<Map>()
                .map((e) => e.cast<String, dynamic>())
                .toList();
        final hasApiKey = apiKeys.any(
          (entry) => '${entry['current_key'] ?? ''}'.trim().isNotEmpty,
        );
        if (!hasApiKey) {
          errors.add('google-services.json client is missing current_key.');
        }
      }

      final hasExampleClient = clients.any((client) {
        final info =
            (client['client_info'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final androidClientInfo =
            (info['android_client_info'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final packageName = '${androidClientInfo['package_name'] ?? ''}'.trim();
        return packageName.contains('com.example.');
      });
      if (hasExampleClient) {
        warnings.add(
          'google-services.json still contains com.example.* client entries. '
          'Consider downloading a clean single-app config.',
        );
      }
    } catch (error) {
      errors.add('Failed to parse android/app/google-services.json: $error');
    }
  }

  final iosGoogleServiceInfo = File('ios/Runner/GoogleService-Info.plist');
  if (!iosGoogleServiceInfo.existsSync()) {
    if (!allowMissingNativeFiles) {
      errors.add('Missing ios/Runner/GoogleService-Info.plist');
    } else {
      warnings.add(
        'ios/Runner/GoogleService-Info.plist not found (allowed by --allow-missing-native-files).',
      );
    }
  } else {
    checks.add('Found ios/Runner/GoogleService-Info.plist');
    final plistRaw = iosGoogleServiceInfo.readAsStringSync();
    final plistValues = _extractPlistStringValues(plistRaw);
    final plistProjectId = plistValues['PROJECT_ID'] ?? '';
    final plistStorageBucket = plistValues['STORAGE_BUCKET'] ?? '';
    final plistSenderId = plistValues['GCM_SENDER_ID'] ?? '';
    final plistAppId = plistValues['GOOGLE_APP_ID'] ?? '';
    final plistBundleId = plistValues['BUNDLE_ID'] ?? '';
    final plistApiKey = plistValues['API_KEY'] ?? '';

    if (plistProjectId != expectedProjectId) {
      errors.add(
        'GoogleService-Info.plist PROJECT_ID ($plistProjectId) does not match '
        'firebase_options.dart ($expectedProjectId).',
      );
    }
    if (plistStorageBucket != expectedStorageBucket) {
      errors.add(
        'GoogleService-Info.plist STORAGE_BUCKET ($plistStorageBucket) does not match '
        'firebase_options.dart ($expectedStorageBucket).',
      );
    }
    if (plistSenderId != expectedSenderId) {
      errors.add(
        'GoogleService-Info.plist GCM_SENDER_ID ($plistSenderId) does not match '
        'firebase_options.dart messagingSenderId ($expectedSenderId).',
      );
    }
    if (plistAppId != expectedIosAppId) {
      errors.add(
        'GoogleService-Info.plist GOOGLE_APP_ID ($plistAppId) does not match '
        'firebase_options.dart iOS appId ($expectedIosAppId).',
      );
    }
    if (plistBundleId != expectedBundleId) {
      errors.add(
        'GoogleService-Info.plist BUNDLE_ID ($plistBundleId) does not match '
        'firebase_options.dart iosBundleId ($expectedBundleId).',
      );
    }
    if (plistApiKey.trim().isEmpty) {
      errors.add('GoogleService-Info.plist API_KEY is empty.');
    }
  }

  return _ValidationResult(
    ok: errors.isEmpty,
    summary: _buildSummary(
      ok: errors.isEmpty,
      checks: checks,
      warnings: warnings,
      errors: errors,
    ),
  );
}

Map<String, String>? _extractPlatformOptions({
  required String source,
  required String platformName,
}) {
  final platformMatch = RegExp(
    'static FirebaseOptions get $platformName => FirebaseOptions\\((.*?)\\);',
    dotAll: true,
  ).firstMatch(source);
  if (platformMatch == null) return null;
  final block = platformMatch.group(1) ?? '';
  final fieldPattern = RegExp(r"([A-Za-z_][A-Za-z0-9_]*)\s*:\s*'([^']*)'");
  final out = <String, String>{};
  for (final match in fieldPattern.allMatches(block)) {
    final key = match.group(1)?.trim() ?? '';
    final value = match.group(2)?.trim() ?? '';
    if (key.isNotEmpty) {
      out[key] = value;
    }
  }
  return out;
}

Map<String, String> _extractPlistStringValues(String plistSource) {
  final pattern = RegExp(
    r'<key>\s*([^<]+?)\s*</key>\s*<string>\s*([^<]*?)\s*</string>',
    dotAll: true,
  );
  final out = <String, String>{};
  for (final match in pattern.allMatches(plistSource)) {
    final key = match.group(1)?.trim() ?? '';
    final value = match.group(2)?.trim() ?? '';
    if (key.isNotEmpty) {
      out[key] = value;
    }
  }
  return out;
}

String _buildSummary({
  required bool ok,
  required List<String> checks,
  required List<String> warnings,
  required List<String> errors,
}) {
  final buffer = StringBuffer();
  buffer.writeln(
    ok
        ? 'Firebase mobile config validation passed.'
        : 'Firebase mobile config validation failed.',
  );
  if (checks.isNotEmpty) {
    buffer.writeln('Checks:');
    for (final check in checks) {
      buffer.writeln('- $check');
    }
  }
  if (warnings.isNotEmpty) {
    buffer.writeln('Warnings:');
    for (final warning in warnings) {
      buffer.writeln('- $warning');
    }
  }
  if (errors.isNotEmpty) {
    buffer.writeln('Errors:');
    for (final error in errors) {
      buffer.writeln('- $error');
    }
  }
  return buffer.toString().trimRight();
}

class _ValidationResult {
  const _ValidationResult({required this.ok, required this.summary});

  final bool ok;
  final String summary;
}
