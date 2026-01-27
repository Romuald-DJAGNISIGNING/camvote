import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../models/admin_models.dart';

abstract class AdminRepository {
  Future<AdminStats> fetchAdminStats();
  Future<List<Election>> fetchElections();
  Future<Election> createElection({
    required String title,
    required ElectionType type,
    required DateTime startAt,
    required DateTime endAt,
    DateTime? registrationDeadline,
    String description,
    String scope,
    String location,
    String timezone,
    String ballotType,
    String eligibility,
  });

  Future<Election> addCandidate({
    required String electionId,
    required Candidate candidate,
  });

  Future<List<VoterAdminRecord>> fetchVoters({
    String query = '',
    CameroonRegion? region,
    VoterStatus? status,
  });

  Future<List<VoterAdminRecord>> runElectoralListCleaning();

  Future<List<AuditEvent>> fetchAuditEvents({
    AuditEventType? type,
  });
}

class ApiAdminRepository implements AdminRepository {
  ApiAdminRepository(this._dio);

  final Dio _dio;

  void _ensureApiConfigured() {
    if (!AppConfig.hasApiBaseUrl) {
      throw StateError('API base URL is not configured.');
    }
  }

  @override
  Future<AdminStats> fetchAdminStats() async {
    _ensureApiConfigured();
    final res = await _dio.get('/admin/stats');
    final data = _asMap(res.data);
    return AdminStats(
      totalRegistered: _asInt(data['totalRegistered']),
      totalVoted: _asInt(data['totalVoted']),
      suspiciousFlags: _asInt(data['suspiciousFlags']),
      activeElections: _asInt(data['activeElections']),
    );
  }

  @override
  Future<List<Election>> fetchElections() async {
    _ensureApiConfigured();
    final res = await _dio.get('/admin/elections');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseElection).toList();
  }

  @override
  Future<Election> createElection({
    required String title,
    required ElectionType type,
    required DateTime startAt,
    required DateTime endAt,
    DateTime? registrationDeadline,
    String description = '',
    String scope = '',
    String location = '',
    String timezone = '',
    String ballotType = '',
    String eligibility = '',
  }) async {
    _ensureApiConfigured();
    final res = await _dio.post(
      '/admin/elections',
      data: {
        'title': title,
        'type': _serializeElectionType(type),
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        if (registrationDeadline != null)
          'registrationDeadline': registrationDeadline.toIso8601String(),
        if (description.trim().isNotEmpty) 'description': description.trim(),
        if (scope.trim().isNotEmpty) 'scope': scope.trim(),
        if (location.trim().isNotEmpty) 'location': location.trim(),
        if (timezone.trim().isNotEmpty) 'timezone': timezone.trim(),
        if (ballotType.trim().isNotEmpty) 'ballotType': ballotType.trim(),
        if (eligibility.trim().isNotEmpty) 'eligibility': eligibility.trim(),
      },
    );
    return _parseElection(_asMap(res.data));
  }

  @override
  Future<Election> addCandidate({
    required String electionId,
    required Candidate candidate,
  }) async {
    _ensureApiConfigured();
    final res = await _dio.post(
      '/admin/elections/$electionId/candidates',
      data: {
        'id': candidate.id,
        'fullName': candidate.fullName,
        'partyName': candidate.partyName,
        'partyAcronym': candidate.partyAcronym,
        'partyColor': candidate.partyColor,
        if (candidate.slogan.trim().isNotEmpty) 'slogan': candidate.slogan.trim(),
        if (candidate.bio.trim().isNotEmpty) 'bio': candidate.bio.trim(),
        if (candidate.campaignUrl.trim().isNotEmpty)
          'campaignUrl': candidate.campaignUrl.trim(),
        if (candidate.avatarUrl.trim().isNotEmpty)
          'avatarUrl': candidate.avatarUrl.trim(),
        if (candidate.runningMate.trim().isNotEmpty)
          'runningMate': candidate.runningMate.trim(),
      },
    );
    return _parseElection(_asMap(res.data));
  }

  @override
  Future<List<VoterAdminRecord>> fetchVoters({
    String query = '',
    CameroonRegion? region,
    VoterStatus? status,
  }) async {
    _ensureApiConfigured();
    final res = await _dio.get(
      '/admin/voters',
      queryParameters: {
        if (query.trim().isNotEmpty) 'query': query.trim(),
        if (region != null) 'region': region.code,
        if (status != null) 'status': _serializeVoterStatus(status),
      },
    );
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseVoter).toList();
  }

  @override
  Future<List<VoterAdminRecord>> runElectoralListCleaning() async {
    _ensureApiConfigured();
    final res = await _dio.post('/admin/voters/cleaning');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseVoter).toList();
  }

  @override
  Future<List<AuditEvent>> fetchAuditEvents({AuditEventType? type}) async {
    _ensureApiConfigured();
    final res = await _dio.get(
      '/admin/audit',
      queryParameters: {
        if (type != null) 'type': _serializeAuditType(type),
      },
    );
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseAudit).toList();
  }

  Election _parseElection(Map<String, dynamic> data) {
    final candidates = _parseCandidates(data['candidates']);
    return Election(
      id: _asString(data['id']),
      title: _asString(data['title']),
      type: _parseElectionType(data['type']),
      startAt: _parseDate(data['startAt']) ?? DateTime.now(),
      endAt: _parseDate(data['endAt']) ?? DateTime.now(),
      registrationDeadline:
          _parseDate(data['registrationDeadline'] ?? data['registration_deadline']),
      description: _asString(data['description']),
      scope: _asString(data['scope'] ?? data['coverage']),
      location: _asString(data['location']),
      timezone: _asString(data['timezone']),
      ballotType: _asString(data['ballotType'] ?? data['ballot_type']),
      eligibility: _asString(data['eligibility']),
      candidates: candidates,
      votesByCandidateId: _parseVotesMap(data['votesByCandidateId']),
      winningPartyByRegion: _parseRegionWinners(data['winningPartyByRegion']),
    );
  }

  List<Candidate> _parseCandidates(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map((c) {
      final name = _asString(c['fullName'] ?? c['name']);
      return Candidate(
        id: _asString(c['id']),
        fullName: name,
        partyName: _asString(c['partyName'] ?? c['party']),
        partyAcronym: _asString(c['partyAcronym'] ?? c['acronym']),
        partyColor: _parseColorInt(c['partyColor'], name),
        slogan: _asString(c['slogan']),
        bio: _asString(c['bio']),
        campaignUrl: _asString(c['campaignUrl'] ?? c['campaign_url']),
        avatarUrl: _asString(c['avatarUrl'] ?? c['avatar_url']),
        runningMate: _asString(c['runningMate'] ?? c['running_mate']),
      );
    }).toList();
  }

  VoterAdminRecord _parseVoter(Map<String, dynamic> data) {
    final region = _parseRegion(data['region']) ?? CameroonRegion.centre;
    return VoterAdminRecord(
      voterId: _asString(data['voterId'] ?? data['id']),
      fullName: _asString(data['fullName'] ?? data['name']),
      region: region,
      age: _asInt(data['age']),
      verified: _asBool(data['verified']),
      hasVoted: _asBool(data['hasVoted']),
      status: _parseVoterStatus(data['status']),
      registeredAt: _parseDate(data['registeredAt']) ?? DateTime.now(),
      cardExpiry: _parseDate(data['cardExpiry']) ?? DateTime.now(),
      deviceFlagged: _asBool(data['deviceFlagged']),
      biometricDuplicateFlag: _asBool(data['biometricDuplicateFlag']),
    );
  }

  AuditEvent _parseAudit(Map<String, dynamic> data) {
    return AuditEvent(
      id: _asString(data['id']),
      type: _parseAuditType(data['type']),
      at: _parseDate(data['at']) ?? DateTime.now(),
      actorRole: _asString(data['actorRole'] ?? data['actor']),
      message: _asString(data['message']),
    );
  }

  Map<String, int> _parseVotesMap(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, int>{};
    raw.forEach((key, value) {
      if (key == null) return;
      out[key.toString()] = _asInt(value);
    });
    return out;
  }

  Map<CameroonRegion, String> _parseRegionWinners(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <CameroonRegion, String>{};
    raw.forEach((key, value) {
      final region = _parseRegion(key);
      if (region == null) return;
      out[region] = _asString(value);
    });
    return out;
  }

  ElectionType _parseElectionType(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'presidential' => ElectionType.presidential,
      'parliamentary' => ElectionType.parliamentary,
      'municipal' => ElectionType.municipal,
      'regional' => ElectionType.regional,
      'senatorial' => ElectionType.senatorial,
      'referendum' => ElectionType.referendum,
      _ => ElectionType.presidential,
    };
  }

  String _serializeElectionType(ElectionType type) {
    return type.name;
  }

  CameroonRegion? _parseRegion(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'ad' || 'adamawa' => CameroonRegion.adamawa,
      'ce' || 'centre' => CameroonRegion.centre,
      'es' || 'east' => CameroonRegion.east,
      'en' || 'far_north' || 'farnorth' => CameroonRegion.farNorth,
      'lt' || 'littoral' => CameroonRegion.littoral,
      'no' || 'north' => CameroonRegion.north,
      'nw' || 'north_west' || 'northwest' => CameroonRegion.northWest,
      'su' || 'south' => CameroonRegion.south,
      'sw' || 'south_west' || 'southwest' => CameroonRegion.southWest,
      'ou' || 'west' => CameroonRegion.west,
      _ => null,
    };
  }

  VoterStatus _parseVoterStatus(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'pending' || 'pending_verification' => VoterStatus.pendingVerification,
      'registered' => VoterStatus.registered,
      'pre_eligible' || 'registered_pre_eligible' => VoterStatus.preEligible,
      'eligible' => VoterStatus.eligible,
      'voted' => VoterStatus.voted,
      'suspended' => VoterStatus.suspended,
      'deceased' => VoterStatus.deceased,
      'archived' => VoterStatus.archived,
      _ => VoterStatus.pendingVerification,
    };
  }

  String _serializeVoterStatus(VoterStatus status) => status.name;

  AuditEventType _parseAuditType(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'election_created' => AuditEventType.electionCreated,
      'candidate_added' => AuditEventType.candidateAdded,
      'results_published' => AuditEventType.resultsPublished,
      'list_cleaned' => AuditEventType.listCleaned,
      'registration_rejected' => AuditEventType.registrationRejected,
      'suspicious_activity' => AuditEventType.suspiciousActivity,
      'device_banned' => AuditEventType.deviceBanned,
      'vote_cast' => AuditEventType.voteCast,
      _ => AuditEventType.suspiciousActivity,
    };
  }

  String _serializeAuditType(AuditEventType type) => type.name;

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  int _parseColorInt(dynamic value, String name) {
    if (value is int) return value;
    if (value is String) {
      final hex = value.replaceAll('#', '').trim();
      if (hex.length == 6) {
        return int.parse('FF$hex', radix: 16);
      }
      if (hex.length == 8) {
        return int.parse(hex, radix: 16);
      }
    }
    return _colorForName(name);
  }

  int _colorForName(String name) {
    final palette = [
      0xFF0A7D2E,
      0xFFC62828,
      0xFFF9A825,
      0xFF1565C0,
      0xFF6A1B9A,
    ];
    if (name.trim().isEmpty) return palette.first;
    final idx = name.hashCode.abs() % palette.length;
    return palette[idx];
  }
}
