import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cam_notification.dart';

class NotificationsRepository {
  static const _storageKey = 'camvote.notifications.v1';

  Future<List<CamNotification>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(CamNotification.fromMap).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAll(List<CamNotification> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toMap()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }
}