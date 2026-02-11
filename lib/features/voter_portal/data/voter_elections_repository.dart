import '../../../core/network/worker_client.dart';
import '../domain/election.dart';

abstract class VoterElectionsRepository {
  Future<List<Election>> fetchAll();
}

class ApiVoterElectionsRepository implements VoterElectionsRepository {
  ApiVoterElectionsRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  @override
  Future<List<Election>> fetchAll() async {
    final response = await _workerClient.get('/v1/voter/elections');
    final items = response['elections'];
    if (items is! List) return const [];
    return items.whereType<Map>().map((doc) {
      final data =
          (doc['data'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      final candidatesRaw = doc['candidates'];
      final candidates = candidatesRaw is List
          ? candidatesRaw
                .whereType<Map>()
                .map((c) {
                  final data =
                      (c['data'] as Map?)?.cast<String, dynamic>() ??
                      const <String, dynamic>{};
                  return {'id': c['id'] ?? '', ...data};
                })
                .toList()
          : const <Map<String, dynamic>>[];
      return _parseElection({
        ...data,
        'id': doc['id'] ?? '',
        'candidates': candidates,
      });
    }).toList();
  }

  Election _parseElection(Map<String, dynamic> data) {
    return Election(
      id: _asString(data['id']),
      type: _parseType(_asString(data['type'])),
      title: _asString(data['title']),
      opensAt: _parseDate(data['opensAt'] ?? data['startAt']) ?? DateTime.now(),
      closesAt: _parseDate(data['closesAt'] ?? data['endAt']) ?? DateTime.now(),
      registrationDeadline: _parseDate(
        data['registrationDeadline'] ?? data['registrationClosesAt'],
      ),
      campaignStartsAt: _parseDate(
        data['campaignStartsAt'] ?? data['campaignStartAt'],
      ),
      campaignEndsAt: _parseDate(
        data['campaignEndsAt'] ?? data['campaignEndAt'],
      ),
      resultsPublishAt: _parseDate(
        data['resultsPublishAt'] ?? data['resultsAt'] ?? data['publishAt'],
      ),
      runoffOpensAt: _parseDate(data['runoffOpensAt'] ?? data['runoffStartAt']),
      runoffClosesAt: _parseDate(data['runoffClosesAt'] ?? data['runoffEndAt']),
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
