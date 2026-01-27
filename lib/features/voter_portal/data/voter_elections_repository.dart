import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../domain/election.dart';

abstract class VoterElectionsRepository {
  Future<List<Election>> fetchAll();
}

class ApiVoterElectionsRepository implements VoterElectionsRepository {
  ApiVoterElectionsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Election>> fetchAll() async {
    if (!AppConfig.hasApiBaseUrl) {
      throw StateError('API base URL is not configured.');
    }
    final res = await _dio.get('/voter/elections');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseElection).toList();
  }

  Election _parseElection(Map<String, dynamic> data) {
    return Election(
      id: _asString(data['id']),
      type: _parseType(_asString(data['type'])),
      title: _asString(data['title']),
      opensAt: _parseDate(data['opensAt']) ?? DateTime.now(),
      closesAt: _parseDate(data['closesAt']) ?? DateTime.now(),
      scopeLabel: _asString(data['scopeLabel'] ?? data['scope']),
      candidates: _parseCandidates(data['candidates']),
    );
  }

  List<Candidate> _parseCandidates(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (c) => Candidate(
            id: _asString(c['id']),
            fullName: _asString(c['fullName'] ?? c['name']),
            partyName: _asString(c['partyName'] ?? c['party']),
            partyAcronym: _asString(c['partyAcronym'] ?? c['acronym']),
          ),
        )
        .toList();
  }

  ElectionType _parseType(String raw) {
    return switch (raw.toLowerCase()) {
      'presidential' => ElectionType.presidential,
      'parliamentary' => ElectionType.parliamentary,
      'municipal' => ElectionType.municipal,
      'regional' => ElectionType.regional,
      'senatorial' => ElectionType.senatorial,
      'referendum' => ElectionType.referendum,
      _ => ElectionType.presidential,
    };
  }

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
