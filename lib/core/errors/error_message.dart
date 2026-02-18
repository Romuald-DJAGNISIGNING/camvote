import 'package:flutter/material.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../network/worker_client.dart';
import '../../features/auth/utils/auth_error_utils.dart';
import '../../features/auth/models/auth_error_codes.dart';

String safeErrorMessage(
  BuildContext context,
  Object? error, {
  String? fallback,
}) {
  final t = AppLocalizations.of(context);
  final fallbackMessage = fallback ?? t.genericErrorLabel;
  if (error == null) return fallbackMessage;

  // WorkerException messages are already sanitized/user-friendly.
  if (error is WorkerException) {
    final message = error.message.trim();
    return message.isEmpty ? fallbackMessage : message;
  }

  final authCode = authErrorCodeFromException(error);
  if (authCode != AuthErrorCodes.unknown) {
    final message = authErrorMessageFromCode(t, authCode);
    if (message.isNotEmpty) return message;
  }

  final raw = error.toString();
  if (raw.trim().isEmpty) return fallbackMessage;
  final lower = raw.toLowerCase();
  if (lower.contains('account not found') ||
      lower.contains('user not found') ||
      lower.contains('user-not-found')) {
    return t.authAccountNotFound;
  }
  if (lower.contains('invalid credentials') ||
      lower.contains('wrong-password') ||
      lower.contains('invalid-credential')) {
    return t.authInvalidCredentials;
  }
  if (lower.contains('firebase') ||
      lower.contains('firestore') ||
      lower.contains('permission') ||
      lower.contains('insufficient permissions') ||
      lower.contains('permission-denied')) {
    return fallbackMessage;
  }
  if (lower.contains('not found') || lower.contains('404')) {
    return fallbackMessage;
  }
  if (lower.contains('network') || lower.contains('timeout')) {
    return t.authNetworkError;
  }
  return fallbackMessage;
}
