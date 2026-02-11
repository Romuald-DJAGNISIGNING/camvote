import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../../features/auth/data/token_store.dart';
import '../../features/auth/models/auth_tokens.dart';

final authTokenStoreProvider = Provider<AuthTokenStore>(
  (ref) => AuthTokenStore(),
);

String _defaultBaseUrl() {
  if (AppConfig.hasApiBaseUrl) return AppConfig.apiBaseUrl;
  // Fallback to deployed Worker if not provided.
  return 'https://camvote.romuald-djagnisigning.workers.dev';
}

String resolvedApiBaseUrl() => _defaultBaseUrl();

bool hasResolvedApiBaseUrl() => resolvedApiBaseUrl().trim().isNotEmpty;

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl(),
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 20),
    ),
  );

  final tokenStore = ref.read(authTokenStoreProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStore.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refresh = await tokenStore.readRefreshToken();
          if (refresh != null && refresh.isNotEmpty) {
            try {
              final fresh = await _refreshTokens(refresh);
              await tokenStore.saveTokens(fresh);

              final req = error.requestOptions;
              req.headers['Authorization'] = 'Bearer ${fresh.accessToken}';
              final retry = await dio.fetch(req);
              return handler.resolve(retry);
            } catch (_) {
              await tokenStore.clear();
            }
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

Future<AuthTokens> _refreshTokens(String refreshToken) async {
  final dio = Dio(BaseOptions(baseUrl: _defaultBaseUrl()));
  final res = await dio.post(
    '/auth/refresh',
    data: {'refresh_token': refreshToken},
  );
  return AuthTokens.fromJson(res.data as Map<String, dynamic>);
}
