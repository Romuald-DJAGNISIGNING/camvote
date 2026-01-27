import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps biometric auth in a clean, testable service.
///
/// NOTE:
/// - This does NOT store biometrics (OS owns that).
/// - This is the *gate* used before sensitive actions (vote confirm, identity actions).
class BiometricGate {
  BiometricGate({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<bool> isSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requireBiometric({
    required String reason,
  }) async {
    try {
      final supported = await isSupported();
      if (!supported) return false;

      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
      return ok;
    } catch (e) {
      debugPrint('BiometricGate error: $e');
      return false;
    }
  }
}
