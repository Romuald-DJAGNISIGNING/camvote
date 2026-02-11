import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_tokens.dart';

class AuthTokenStore {
  AuthTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'auth_access_token';
  static const _kRefreshToken = 'auth_refresh_token';
  static const _kExpiresAt = 'auth_expires_at';

  Future<AuthTokens?> readTokens() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);
    if (access == null || refresh == null) return null;

    final expRaw = await _storage.read(key: _kExpiresAt);
    final exp = expRaw == null ? null : DateTime.tryParse(expRaw);

    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: exp,
    );
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _kAccessToken, value: tokens.accessToken);
    await _storage.write(key: _kRefreshToken, value: tokens.refreshToken);
    await _storage.write(
      key: _kExpiresAt,
      value: tokens.expiresAt?.toIso8601String(),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kExpiresAt);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _kAccessToken);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _kRefreshToken);
  }
}
