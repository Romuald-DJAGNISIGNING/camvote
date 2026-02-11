import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'device_identity_policy.dart';

class VoteAttemptPolicy {
  static const _kFailedByElection = 'vote_failed_by_election';
  static const _kFlaggedByElection = 'vote_flagged_by_election';

  static const int maxFailures = 3;

  Future<bool> isFlagged(String electionId) async {
    final prefs = await SharedPreferences.getInstance();
    final flagged = prefs.getStringList(_kFlaggedByElection) ?? <String>[];
    return flagged.contains(electionId);
  }

  Future<void> recordFailure(String electionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFailedByElection);
    final map = _decode(raw);
    final count = (map[electionId] ?? 0) + 1;
    map[electionId] = count;

    if (count >= maxFailures) {
      await _flagElection(prefs, electionId);
      await DeviceIdentityPolicy().banForMonths(3);
    }

    await prefs.setString(_kFailedByElection, jsonEncode(map));
  }

  Future<void> recordDuplicateAttempt(String electionId) async {
    await recordFailure(electionId);
  }

  Future<void> clear(String electionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kFailedByElection);
    final map = _decode(raw);
    map.remove(electionId);
    await prefs.setString(_kFailedByElection, jsonEncode(map));
  }

  Map<String, int> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return <String, int>{};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return <String, int>{};
    return decoded.map(
      (k, v) => MapEntry(k, v is int ? v : int.tryParse('$v') ?? 0),
    );
  }

  Future<void> _flagElection(SharedPreferences prefs, String electionId) async {
    final flagged = prefs.getStringList(_kFlaggedByElection) ?? <String>[];
    if (flagged.contains(electionId)) return;
    await prefs.setStringList(_kFlaggedByElection, [...flagged, electionId]);
  }
}
