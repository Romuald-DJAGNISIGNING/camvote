import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueuedRequest {
  const OfflineQueuedRequest({
    required this.id,
    required this.path,
    required this.data,
    required this.authRequired,
    required this.scopeKey,
    required this.queueType,
    required this.createdAt,
    required this.attempts,
    required this.lastError,
  });

  final String id;
  final String path;
  final Map<String, dynamic> data;
  final bool authRequired;
  final String scopeKey;
  final String queueType;
  final DateTime createdAt;
  final int attempts;
  final String lastError;

  OfflineQueuedRequest copyWith({
    int? attempts,
    String? lastError,
  }) {
    return OfflineQueuedRequest(
      id: id,
      path: path,
      data: data,
      authRequired: authRequired,
      scopeKey: scopeKey,
      queueType: queueType,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'data': data,
      'authRequired': authRequired,
      'scopeKey': scopeKey,
      'queueType': queueType,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'lastError': lastError,
    };
  }

  static OfflineQueuedRequest fromMap(Map<String, dynamic> map) {
    return OfflineQueuedRequest(
      id: map['id']?.toString() ?? '',
      path: map['path']?.toString() ?? '',
      data: (map['data'] is Map)
          ? Map<String, dynamic>.from(map['data'] as Map)
          : const <String, dynamic>{},
      authRequired: map['authRequired'] == true,
      scopeKey: map['scopeKey']?.toString() ?? 'public',
      queueType: map['queueType']?.toString() ?? 'generic',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      lastError: map['lastError']?.toString() ?? '',
    );
  }
}

class OfflineSyncStore {
  OfflineSyncStore._();

  static const _queueKey = 'camvote.offline.post_queue.v1';
  static const _getCacheKey = 'camvote.offline.get_cache.v1';
  static const _maxQueuedItems = 150;
  static const _maxCachedGets = 180;

  static String _buildGetCacheId({
    required String scopeKey,
    required String path,
    Map<String, dynamic>? queryParameters,
  }) {
    final query = <MapEntry<String, dynamic>>[
      ...?queryParameters?.entries.where((entry) => entry.value != null),
    ]..sort((a, b) => a.key.compareTo(b.key));
    final queryString = query
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}',
        )
        .join('&');
    return '$scopeKey|$path|$queryString';
  }

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<List<OfflineQueuedRequest>> loadQueuedRequests() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <OfflineQueuedRequest>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <OfflineQueuedRequest>[];
      final list = <OfflineQueuedRequest>[];
      for (final item in decoded.whereType<Map>()) {
        try {
          final mapped = OfflineQueuedRequest.fromMap(
            item.cast<String, dynamic>(),
          );
          if (mapped.id.isEmpty || mapped.path.isEmpty) continue;
          list.add(mapped);
        } catch (_) {
          // Skip malformed entries and keep the rest.
        }
      }
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    } catch (_) {
      return const <OfflineQueuedRequest>[];
    }
  }

  static Future<void> saveQueuedRequests(
    List<OfflineQueuedRequest> requests,
  ) async {
    final prefs = await _prefs();
    final capped = requests.length > _maxQueuedItems
        ? requests.sublist(requests.length - _maxQueuedItems)
        : requests;
    final encoded = jsonEncode(capped.map((entry) => entry.toMap()).toList());
    await prefs.setString(_queueKey, encoded);
  }

  static Future<OfflineQueuedRequest> enqueuePost({
    required String path,
    required Map<String, dynamic> data,
    required bool authRequired,
    required String scopeKey,
    String queueType = 'generic',
  }) async {
    final requests = await loadQueuedRequests();
    final id = _buildQueueId(path, scopeKey);
    final request = OfflineQueuedRequest(
      id: id,
      path: path,
      data: data,
      authRequired: authRequired,
      scopeKey: scopeKey,
      queueType: queueType.trim().isEmpty ? 'generic' : queueType.trim(),
      createdAt: DateTime.now().toUtc(),
      attempts: 0,
      lastError: '',
    );
    requests.add(request);
    await saveQueuedRequests(requests);
    return request;
  }

  static Future<void> removeQueuedRequest(String id) async {
    final requests = await loadQueuedRequests();
    final filtered = requests.where((entry) => entry.id != id).toList();
    if (filtered.length == requests.length) return;
    await saveQueuedRequests(filtered);
  }

  static Future<void> markRetryFailure(
    String id, {
    required String error,
  }) async {
    final requests = await loadQueuedRequests();
    final updated = <OfflineQueuedRequest>[];
    for (final entry in requests) {
      if (entry.id == id) {
        updated.add(
          entry.copyWith(
            attempts: entry.attempts + 1,
            lastError: error.trim(),
          ),
        );
      } else {
        updated.add(entry);
      }
    }
    await saveQueuedRequests(updated);
  }

  static Future<int> pendingCount({String? queueType}) async {
    final requests = await loadQueuedRequests();
    final normalized = queueType?.trim();
    if (normalized == null || normalized.isEmpty) {
      return requests.length;
    }
    return requests.where((entry) => entry.queueType == normalized).length;
  }

  static Future<void> cacheGetResponse({
    required String scopeKey,
    required String path,
    Map<String, dynamic>? queryParameters,
    required Map<String, dynamic> response,
  }) async {
    final prefs = await _prefs();
    final raw = prefs.getString(_getCacheKey);
    Map<String, dynamic> cache = <String, dynamic>{};
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          cache = decoded.cast<String, dynamic>();
        }
      } catch (_) {
        cache = <String, dynamic>{};
      }
    }

    final key = _buildGetCacheId(
      scopeKey: scopeKey,
      path: path,
      queryParameters: queryParameters,
    );
    cache[key] = {
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'response': response,
    };

    if (cache.length > _maxCachedGets) {
      final sortable = cache.entries.map((entry) {
        final value = entry.value;
        if (value is! Map) {
          return (
            key: entry.key,
            savedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          );
        }
        final savedAt =
            DateTime.tryParse(value['savedAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
        return (key: entry.key, savedAt: savedAt);
      }).toList()
        ..sort((a, b) => a.savedAt.compareTo(b.savedAt));
      final toRemove = sortable.take(cache.length - _maxCachedGets).toList();
      for (final item in toRemove) {
        cache.remove(item.key);
      }
    }

    await prefs.setString(_getCacheKey, jsonEncode(cache));
  }

  static Future<Map<String, dynamic>?> loadCachedGetResponse({
    required String scopeKey,
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    final prefs = await _prefs();
    final raw = prefs.getString(_getCacheKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final cache = decoded.cast<String, dynamic>();
      final key = _buildGetCacheId(
        scopeKey: scopeKey,
        path: path,
        queryParameters: queryParameters,
      );
      final item = cache[key];
      if (item is! Map) return null;
      final response = item['response'];
      if (response is! Map) return null;
      return Map<String, dynamic>.from(response);
    } catch (_) {
      return null;
    }
  }

  static String _buildQueueId(String path, String scopeKey) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final hash = Object.hash(path, scopeKey, stamp);
    return 'offline_${hash.abs()}_$stamp';
  }
}
