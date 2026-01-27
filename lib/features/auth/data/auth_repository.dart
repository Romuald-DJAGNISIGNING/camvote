import 'package:dio/dio.dart';
import '../../../core/theme/role_theme.dart';
import '../models/auth_session.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    required String identifier,
    required String password,
    required AppRole role,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {
        'identifier': identifier.trim(),
        'password': password,
        'role': role.apiValue,
      },
    );

    final data = res.data as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(data['tokens'] as Map<String, dynamic>);
    final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

    return AuthSession(user: user, tokens: tokens);
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final res = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    final data = res.data as Map<String, dynamic>;
    return AuthTokens.fromJson(data);
  }

  Future<AuthUser> me() async {
    final res = await _dio.get('/auth/me');
    return AuthUser.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<void> requestPasswordReset(String emailOrId) async {
    await _dio.post(
      '/auth/request-password-reset',
      data: {'identifier': emailOrId.trim()},
    );
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/auth/me');
  }
}
