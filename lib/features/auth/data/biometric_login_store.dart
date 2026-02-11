import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricLoginProfile {
  final String userId;
  final String displayName;
  final String role;

  const BiometricLoginProfile({
    required this.userId,
    required this.displayName,
    required this.role,
  });
}

class BiometricLoginStore {
  BiometricLoginStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kEnabled = 'biometric_login_enabled';
  static const _kUserId = 'biometric_login_user_id';
  static const _kDisplayName = 'biometric_login_display_name';
  static const _kRole = 'biometric_login_role';

  Future<bool> isEnabled() async {
    final raw = await _storage.read(key: _kEnabled);
    return raw == 'true';
  }

  Future<BiometricLoginProfile?> readProfile() async {
    final userId = await _storage.read(key: _kUserId);
    if (userId == null || userId.isEmpty) return null;
    final displayName = await _storage.read(key: _kDisplayName) ?? '';
    final role = await _storage.read(key: _kRole) ?? '';
    return BiometricLoginProfile(
      userId: userId,
      displayName: displayName,
      role: role,
    );
  }

  Future<void> enableProfile(BiometricLoginProfile profile) async {
    await _storage.write(key: _kEnabled, value: 'true');
    await _storage.write(key: _kUserId, value: profile.userId);
    await _storage.write(key: _kDisplayName, value: profile.displayName);
    await _storage.write(key: _kRole, value: profile.role);
  }

  Future<void> disable() async {
    await _storage.write(key: _kEnabled, value: 'false');
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kDisplayName);
    await _storage.delete(key: _kRole);
  }
}
