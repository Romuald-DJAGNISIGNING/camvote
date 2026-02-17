import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cam_notification.dart';

class NotificationsRepository {
  static const _storageKey = 'camvote.notifications.v2';
  static const _legacyStorageKey = 'camvote.notifications.v1';

  String _scopedKey(String scopeKey) => '$_storageKey.$scopeKey';

  Future<List<CamNotification>> loadAll({String scopeKey = 'guest'}) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = _scopedKey(scopeKey);
    String? raw = prefs.getString(scopedKey);
    raw ??= prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await _clearCorrupted(prefs, scopedKey: scopedKey);
        return [];
      }

      final out = <CamNotification>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          out.add(CamNotification.fromMap(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Skip malformed records but keep valid notifications.
        }
      }
      out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return out;
    } catch (_) {
      await _clearCorrupted(prefs, scopedKey: scopedKey);
      return [];
    }
  }

  Future<void> saveAll(
    List<CamNotification> items, {
    String scopeKey = 'guest',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toMap()).toList();
    await prefs.setString(_scopedKey(scopeKey), jsonEncode(list));
  }

  Future<void> _clearCorrupted(
    SharedPreferences prefs, {
    required String scopedKey,
  }) async {
    try {
      await prefs.remove(scopedKey);
    } catch (_) {
      // Fail open.
    }
    try {
      await prefs.remove(_legacyStorageKey);
    } catch (_) {
      // Fail open.
    }
  }
}
