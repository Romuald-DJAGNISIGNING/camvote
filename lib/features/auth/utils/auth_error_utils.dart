import 'package:firebase_auth/firebase_auth.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

import '../../../core/network/worker_client.dart';
import '../models/auth_error_codes.dart';

String authErrorCodeFromException(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code.toLowerCase()) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-email':
        return AuthErrorCodes.invalidCredentials;
      case 'user-not-found':
        return AuthErrorCodes.accountNotFound;
      case 'too-many-requests':
        return AuthErrorCodes.tooManyRequests;
      case 'network-request-failed':
        return AuthErrorCodes.networkError;
      default:
        return AuthErrorCodes.unknown;
    }
  }

  if (error is WorkerException) {
    final raw = error.message.toLowerCase();
    if (error.statusCode == 404 ||
        raw.contains('account not found') ||
        raw.contains('user not found')) {
      return AuthErrorCodes.accountNotFound;
    }
    if (raw.contains('too many')) {
      return AuthErrorCodes.tooManyRequests;
    }
    if (raw.contains('network') || raw.contains('timeout')) {
      return AuthErrorCodes.networkError;
    }
  }

  final text = error.toString().toLowerCase();
  if (text.contains(AuthErrorCodes.accountArchived)) {
    return AuthErrorCodes.accountArchived;
  }
  if (text.contains(AuthErrorCodes.verificationRequired)) {
    return AuthErrorCodes.verificationRequired;
  }
  if (text.contains(AuthErrorCodes.accountNotFound)) {
    return AuthErrorCodes.accountNotFound;
  }
  if (text.contains(AuthErrorCodes.invalidCredentials)) {
    return AuthErrorCodes.invalidCredentials;
  }
  if (text.contains(AuthErrorCodes.tooManyRequests)) {
    return AuthErrorCodes.tooManyRequests;
  }
  if (text.contains(AuthErrorCodes.networkError)) {
    return AuthErrorCodes.networkError;
  }
  if (text.contains(AuthErrorCodes.mustChangePassword)) {
    return AuthErrorCodes.mustChangePassword;
  }
  if (text.contains('account not found') || text.contains('user-not-found')) {
    return AuthErrorCodes.accountNotFound;
  }
  if (text.contains('wrong-password') ||
      text.contains('invalid-credential') ||
      text.contains('invalid credential')) {
    return AuthErrorCodes.invalidCredentials;
  }
  if (text.contains('network') || text.contains('timeout')) {
    return AuthErrorCodes.networkError;
  }
  if (text.contains('too many')) {
    return AuthErrorCodes.tooManyRequests;
  }
  return AuthErrorCodes.unknown;
}

String authErrorMessageFromCode(AppLocalizations t, String code) {
  return switch (code) {
    AuthErrorCodes.verificationRequired => t.loginRequiresVerification,
    AuthErrorCodes.accountArchived => t.accountArchivedMessage,
    AuthErrorCodes.accountNotFound => t.authAccountNotFound,
    AuthErrorCodes.invalidCredentials => t.authInvalidCredentials,
    AuthErrorCodes.tooManyRequests => t.authTooManyRequests,
    AuthErrorCodes.networkError => t.authNetworkError,
    AuthErrorCodes.mustChangePassword => t.authMustChangePassword,
    _ => t.genericErrorLabel,
  };
}
