import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../firebase/firebase_auth_scope.dart';
import '../offline/offline_sync_store.dart';

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
    String? parseDetail(dynamic detail) {
      if (detail == null) return null;
      if (detail is String) {
        final value = detail.trim();
        return value.isEmpty ? null : value;
      }
      if (detail is List) {
        for (final item in detail) {
          final parsed = parseDetail(item);
          if (parsed != null && parsed.isNotEmpty) return parsed;
        }
        return null;
      }
      if (detail is Map) {
        if (detail['message'] != null) {
          final nested = detail['message']?.toString().trim();
          if (nested != null && nested.isNotEmpty) return nested;
        }
        if (detail['detail'] != null) {
          final nested = parseDetail(detail['detail']);
          if (nested != null && nested.isNotEmpty) return nested;
        }
      }
      return null;
    }

    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final nested = error['message']?.toString().trim();
        if (nested != null && nested.isNotEmpty) return nested;
      }
      final detail = parseDetail(data['detail']);
      if (detail != null && detail.isNotEmpty) return detail;
      final top = data['message']?.toString().trim();
      if (top != null && top.isNotEmpty) return top;
    }
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        final nested = error['message']?.toString().trim();
        if (nested != null && nested.isNotEmpty) return nested;
      }
      final detail = parseDetail(data['detail']);
      if (detail != null && detail.isNotEmpty) return detail;
      final top = data['message']?.toString().trim();
      if (top != null && top.isNotEmpty) return top;
    }
    return null;
  }

  String _friendlyMessage(String? message, int? statusCode) {
    final normalized = message?.trim() ?? '';
    if (statusCode == 400 &&
        (normalized.isEmpty || normalized.toLowerCase() == 'bad request')) {
      return 'Request rejected. Please check required fields and try again.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'You are not authorized. Please sign in again.';
    }
    if (statusCode == 404) {
      return 'Service endpoint not found. Please try again later.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Service is temporarily unavailable. Please try again.';
    }
    if (normalized.isNotEmpty) return normalized;
    return 'Worker request failed.';
  }

  bool _shouldRetry(DioException error, int attempt) {
    if (attempt >= 1) return false;
    final status = error.response?.statusCode ?? 0;
    if (status >= 500 && status <= 599) return true;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
    }
  }

  bool _isConnectivityIssue(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
    }
  }

  Future<void> _waitBeforeRetry(int attempt) {
    final delay = 250 * (attempt + 1);
    return Future<void>.delayed(Duration(milliseconds: delay));
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authRequired = true,
  }) async {
    String? token;
    final scopeKey = _scopeKey(authRequired: authRequired);
    if (authRequired) {
      token = await _auth.currentUser?.getIdToken();
      if (token == null || token.isEmpty) {
        throw WorkerException('Sign in required.');
      }
    }

    for (var attempt = 0; attempt < 2; attempt += 1) {
      try {
        final response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: Options(
            headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          ),
        );
        final body = response.data;
        if (body is Map<String, dynamic>) {
          unawaited(
            OfflineSyncStore.cacheGetResponse(
              scopeKey: scopeKey,
              path: path,
              queryParameters: queryParameters,
              response: body,
            ),
          );
          return body;
        }
        if (body is Map) {
          final mapped = body.cast<String, dynamic>();
          unawaited(
            OfflineSyncStore.cacheGetResponse(
              scopeKey: scopeKey,
              path: path,
              queryParameters: queryParameters,
              response: mapped,
            ),
          );
          return mapped;
        }
        throw WorkerException('Unexpected worker response.');
      } on DioException catch (e) {
        if (_shouldRetry(e, attempt)) {
          await _waitBeforeRetry(attempt);
          continue;
        }
        if (_isConnectivityIssue(e)) {
          final cached = await OfflineSyncStore.loadCachedGetResponse(
            scopeKey: scopeKey,
            path: path,
            queryParameters: queryParameters,
          );
          if (cached != null && cached.isNotEmpty) {
            return cached;
          }
        }
        final status = e.response?.statusCode;
        final message =
            _extractErrorMessage(e.response?.data) ?? e.message?.trim();
        throw WorkerException(
          _friendlyMessage(message, status),
          statusCode: status,
        );
      }
    }
    throw WorkerException('Worker request failed.');
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    bool authRequired = true,
    bool allowOfflineQueue = false,
    String queueType = 'generic',
    bool replayingOfflineQueue = false,
  }) async {
    String? token;
    final payload = data ?? const <String, dynamic>{};
    final scopeKey = _scopeKey(authRequired: authRequired);
    if (authRequired) {
      token = await _auth.currentUser?.getIdToken();
      if (token == null || token.isEmpty) {
        throw WorkerException('Sign in required.');
      }
    }

    for (var attempt = 0; attempt < 2; attempt += 1) {
      try {
        final response = await _dio.post(
          path,
          data: payload,
          options: Options(
            headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          ),
        );
        final body = response.data;
        if (body is Map<String, dynamic>) return body;
        if (body is Map) return body.cast<String, dynamic>();
        throw WorkerException('Unexpected worker response.');
      } on DioException catch (e) {
        if (_shouldRetry(e, attempt)) {
          await _waitBeforeRetry(attempt);
          continue;
        }
        if (allowOfflineQueue &&
            !replayingOfflineQueue &&
            _isConnectivityIssue(e)) {
          final queued = await OfflineSyncStore.enqueuePost(
            path: path,
            data: payload,
            authRequired: authRequired,
            scopeKey: scopeKey,
            queueType: queueType,
          );
          return <String, dynamic>{
            'ok': true,
            'queued': true,
            'status': 'queued_offline',
            'offlineQueueId': queued.id,
          };
        }
        final status = e.response?.statusCode;
        final message =
            _extractErrorMessage(e.response?.data) ?? e.message?.trim();
        throw WorkerException(
          _friendlyMessage(message, status),
          statusCode: status,
        );
      }
    }
    throw WorkerException('Worker request failed.');
  }

  String _scopeKey({required bool authRequired}) {
    if (!authRequired) return 'public';
    final uid = _auth.currentUser?.uid.trim() ?? '';
    return uid.isEmpty ? 'auth_user' : 'user_$uid';
  }
}

final workerClientProvider = Provider<WorkerClient>((ref) {
  return WorkerClient();
});
