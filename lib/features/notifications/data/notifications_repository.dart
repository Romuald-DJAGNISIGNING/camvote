import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cam_notification.dart';

class NotificationsRepository {
  static const _storageKey = 'camvote.notifications.v2';
  static const _legacyStorageKey = 'camvote.notifications.v1';

  String _scopedKey(String scopeKey) => '$_storageKey.$scopeKey';

  Future<List<CamNotification>> loadAll({String scopeKey = 'guest'}) async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_scopedKey(scopeKey));
    raw ??= prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(CamNotification.fromMap).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAll(
    List<CamNotification> items, {
    String scopeKey = 'guest',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toMap()).toList();
    await prefs.setString(_scopedKey(scopeKey), jsonEncode(list));
  }
}
