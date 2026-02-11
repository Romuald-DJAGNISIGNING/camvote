import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../firebase/firebase_auth_scope.dart';

String _defaultWorkerBaseUrl() {
  if (AppConfig.hasApiBaseUrl) return AppConfig.apiBaseUrl;
  // Fallback to deployed Worker if nothing is set.
  return 'https://camvote.romuald-djagnisigning.workers.dev';
}

class WorkerException implements Exception {
  final String message;
  final int? statusCode;

  WorkerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class WorkerClient {
  WorkerClient({Dio? dio, FirebaseAuth? auth})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _defaultWorkerBaseUrl(),
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 25),
              sendTimeout: const Duration(seconds: 20),
            ),
          ),
      _authOverride = auth;

  final Dio _dio;
  final FirebaseAuth? _authOverride;

  FirebaseAuth get _auth {
    final override = _authOverride;
    if (override != null) return override;
    if (!kIsWeb) return FirebaseAuth.instance;
    final app = resolveFirebaseAppForScope();
    return FirebaseAuth.instanceFor(app: app);
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final nested = error['message']?.toString().trim();
        if (nested != null && nested.isNotEmpty) return nested;
      }
      final top = data['message']?.toString().trim();
      if (top != null && top.isNotEmpty) return top;
    }
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final nested = error['message']?.toString().trim();
        if (nested != null && nested.isNotEmpty) return nested;
      }
      final top = data['message']?.toString().trim();
      if (top != null && top.isNotEmpty) return top;
    }
    return null;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authRequired = true,
  }) async {
    String? token;
    if (authRequired) {
      token = await _auth.currentUser?.getIdToken();
      if (token == null || token.isEmpty) {
        throw WorkerException('Sign in required.');
      }
    }

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      if (body is Map) return body.cast<String, dynamic>();
      throw WorkerException('Unexpected worker response.');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data) ?? e.message;
      throw WorkerException(
        message ?? 'Worker request failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    bool authRequired = true,
  }) async {
    String? token;
    if (authRequired) {
      token = await _auth.currentUser?.getIdToken();
      if (token == null || token.isEmpty) {
        throw WorkerException('Sign in required.');
      }
    }

    try {
      final response = await _dio.post(
        path,
        data: data ?? const <String, dynamic>{},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      if (body is Map) return body.cast<String, dynamic>();
      throw WorkerException('Unexpected worker response.');
    } on DioException catch (e) {
      final message = _extractErrorMessage(e.response?.data) ?? e.message;
      throw WorkerException(
        message ?? 'Worker request failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

final workerClientProvider = Provider<WorkerClient>((ref) {
  return WorkerClient();
});
