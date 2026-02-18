import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/network/worker_client.dart';
import '../models/admin_models.dart';

abstract class AdminRepository {
  Future<AdminStats> fetchAdminStats();
  Future<VoterDemographics> fetchVoterDemographics();
  Future<List<Election>> fetchElections();
  Future<Election> createElection({
    required String title,
    required ElectionType type,
    required DateTime startAt,
    required DateTime endAt,
    DateTime? registrationDeadline,
    DateTime? campaignStartsAt,
    DateTime? campaignEndsAt,
    DateTime? resultsPublishAt,
    DateTime? runoffOpensAt,
    DateTime? runoffClosesAt,
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

  Future<void> decideRegistration({
    required String registrationId,
    required bool approve,
    String? reason,
    String? voterId,
  });

  Future<List<VoterAdminRecord>> fetchVoters({
    String query = '',
    CameroonRegion? region,
    VoterStatus? status,
  });

  Future<List<ObserverAdminRecord>> fetchObservers({String query = ''});

  Future<ObserverAdminRecord> setObserverRole({
    required String identifier,
    required bool grant,
  });
  Future<ObserverAdminRecord> createObserver({
    required String fullName,
    required String email,
    required String temporaryPassword,
    String username,
  });
  Future<void> deleteObserver({required String identifier});

  Future<List<VoterAdminRecord>> runElectoralListCleaning();

  Future<List<AuditEvent>> fetchAuditEvents({AuditEventType? type});
}

class ApiAdminRepository implements AdminRepository {
  ApiAdminRepository({FirebaseFirestore? firestore, WorkerClient? workerClient})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _workerClient = workerClient ?? WorkerClient();

  final FirebaseFirestore _firestore;
  final WorkerClient _workerClient;

  @override
  Future<AdminStats> fetchAdminStats() async {
    try {
      final response = await _workerClient.get('/v1/admin/stats');
      return AdminStats(
        totalRegistered: _firstNonZero([
          response['totalRegisteredVoters'],
          response['totalRegistered'],
        ]),
        totalVoted: _asInt(response['totalVoted']),
        suspiciousFlags: _asInt(response['suspiciousFlags']),
        activeElections: _asInt(response['activeElections']),
        adminCount: _asInt(response['adminCount']),
        observerCount: _asInt(response['observerCount']),
      );
    } catch (error) {
      if (_isUnauthorized(error)) {
        final observerFallback = await _tryFetchPublicStatsFallback();
        if (observerFallback != null) {
          return observerFallback;
        }
      }

      try {
        final verifiedUsersSnap = await _firestore
            .collection('users')
            .where('verified', isEqualTo: true)
            .get();
        final adminUsersSnap = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .get();
        final observerUsersSnap = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'observer')
            .get();
        final votesSnap = await _firestore.collection('votes').get();
        final deviceFlagsSnap = await _firestore
            .collection('device_risks')
            .where('status', isEqualTo: 'flagged')
            .get();
        final electionsSnap = await _firestore.collection('elections').get();
        final now = DateTime.now();
        final active = electionsSnap.docs.where((doc) {
          final data = doc.data();
          final endAt = _parseDate(data['endAt'] ?? data['closesAt']);
          return endAt == null || endAt.isAfter(now);
        }).length;
        final verifiedVoters = verifiedUsersSnap.docs.where((doc) {
          final role = _asString(doc.data()['role']).toLowerCase();
          return role.isEmpty || role == 'voter';
        }).length;

        return AdminStats(
          totalRegistered: verifiedVoters,
          totalVoted: votesSnap.size,
          suspiciousFlags: deviceFlagsSnap.size,
          activeElections: active,
          adminCount: adminUsersSnap.size,
          observerCount: observerUsersSnap.size,
        );
      } catch (_) {
        final fallback = await _tryFetchPublicStatsFallback();
        if (fallback != null) {
          return fallback;
        }
        rethrow;
      }
    }
  }

  @override
  Future<VoterDemographics> fetchVoterDemographics() async {
    try {
      final response = await _workerClient.get(
        '/v1/admin/analytics/voter-demographics',
      );
      final rawBands = response['bands'];
      final bands = <AgeBandDistribution>[];
      if (rawBands is List) {
        for (final raw in rawBands) {
          if (raw is! Map) continue;
          final map = raw.cast<String, dynamic>();
          bands.add(
            AgeBandDistribution(
              key: _asString(map['key']),
              label: _asString(map['label']),
              count: _asInt(map['count']),
              percent: _asDouble(map['percent']),
            ),
          );
        }
      }
      final derived = (response['derived'] is Map)
          ? (response['derived'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final youthRaw = (derived['youth'] is Map)
          ? (derived['youth'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final adultRaw = (derived['adult'] is Map)
          ? (derived['adult'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final seniorRaw = (derived['senior'] is Map)
          ? (derived['senior'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};

      return VoterDemographics(
        total: _asInt(response['total']),
        bands: bands,
        youth: DerivedAgeDistribution(
          count: _asInt(youthRaw['count']),
          percent: _asDouble(youthRaw['percent']),
        ),
        adult: DerivedAgeDistribution(
          count: _asInt(adultRaw['count']),
          percent: _asDouble(adultRaw['percent']),
        ),
        senior: DerivedAgeDistribution(
          count: _asInt(seniorRaw['count']),
          percent: _asDouble(seniorRaw['percent']),
        ),
      );
    } catch (_) {
      final voters = await fetchVoters();
      return _computeDemographicsFromVoters(voters);
    }
  }

  @override
  Future<List<Election>> fetchElections() async {
    try {
      final response = await _workerClient.get('/v1/admin/elections');
      final items = response['elections'];
      if (items is! List) return const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(_parseElectionFromWorker)
          .toList();
    } catch (_) {
      final snap = await _firestore.collection('elections').get();
      final out = <Election>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final candidatesSnap = await _firestore
            .collection('elections/${doc.id}/candidates')
            .get();
        final candidates = candidatesSnap.docs
            .map((c) => _parseCandidate({'id': c.id, ...c.data()}))
            .toList();
        final resultSnap = await _firestore.doc('results/${doc.id}').get();
        final resultData = resultSnap.data() ?? const <String, dynamic>{};
        out.add(
          _parseElection({
            ...data,
            'id': doc.id,
            'candidates': candidates,
            'votesByCandidateId':
                resultData['counts'] ?? data['votesByCandidateId'],
            'winningPartyByRegion':
                resultData['winningPartyByRegion'] ??
                data['winningPartyByRegion'],
          }),
        );
      }
      return out;
    }
  }

  @override
  Future<Election> createElection({
    required String title,
    required ElectionType type,
    required DateTime startAt,
    required DateTime endAt,
    DateTime? registrationDeadline,
    DateTime? campaignStartsAt,
    DateTime? campaignEndsAt,
    DateTime? resultsPublishAt,
    DateTime? runoffOpensAt,
    DateTime? runoffClosesAt,
    String description = '',
    String scope = '',
    String location = '',
    String timezone = '',
    String ballotType = '',
    String eligibility = '',
  }) async {
    try {
      final response = await _workerClient.post(
        '/v1/admin/elections',
        data: {
          'title': title,
          'type': _serializeElectionType(type),
          'startAt': startAt.toIso8601String(),
          'endAt': endAt.toIso8601String(),
          if (registrationDeadline != null)
            'registrationDeadline': registrationDeadline.toIso8601String(),
          if (campaignStartsAt != null)
            'campaignStartsAt': campaignStartsAt.toIso8601String(),
          if (campaignEndsAt != null)
            'campaignEndsAt': campaignEndsAt.toIso8601String(),
          if (resultsPublishAt != null)
            'resultsPublishAt': resultsPublishAt.toIso8601String(),
          if (runoffOpensAt != null)
            'runoffOpensAt': runoffOpensAt.toIso8601String(),
          if (runoffClosesAt != null)
            'runoffClosesAt': runoffClosesAt.toIso8601String(),
          'description': description.trim(),
          'scope': scope.trim(),
          'location': location.trim(),
          'timezone': timezone.trim(),
          'ballotType': ballotType.trim(),
          'eligibility': eligibility.trim(),
        },
      );
      final id = _asString(response['id']);
      final data = (response['election'] as Map<String, dynamic>?) ?? {};
      final mapped = {'id': id, ...data, 'candidates': const <Candidate>[]};
      return _parseElection(mapped);
    } catch (_) {
      final ref = _firestore.collection('elections').doc();
      final payload = <String, dynamic>{
        'title': title,
        'type': _serializeElectionType(type),
        'startAt': Timestamp.fromDate(startAt),
        'endAt': Timestamp.fromDate(endAt),
        if (registrationDeadline != null)
          'registrationDeadline': Timestamp.fromDate(registrationDeadline),
        if (campaignStartsAt != null)
          'campaignStartsAt': Timestamp.fromDate(campaignStartsAt),
        if (campaignEndsAt != null)
          'campaignEndsAt': Timestamp.fromDate(campaignEndsAt),
        if (resultsPublishAt != null)
          'resultsPublishAt': Timestamp.fromDate(resultsPublishAt),
        if (runoffOpensAt != null)
          'runoffOpensAt': Timestamp.fromDate(runoffOpensAt),
        if (runoffClosesAt != null)
          'runoffClosesAt': Timestamp.fromDate(runoffClosesAt),
        'description': description.trim(),
        'scope': scope.trim(),
        'location': location.trim(),
        'timezone': timezone.trim(),
        'ballotType': ballotType.trim(),
        'eligibility': eligibility.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await ref.set(payload);
      return _parseElection({
        ...payload,
        'id': ref.id,
        'candidates': const <Candidate>[],
      });
    }
  }

  @override
  Future<Election> addCandidate({
    required String electionId,
    required Candidate candidate,
  }) async {
    try {
      await _workerClient.post(
        '/v1/admin/elections/candidate',
        data: {
          'electionId': electionId,
          'id': candidate.id,
          'fullName': candidate.fullName,
          'partyName': candidate.partyName,
          'partyAcronym': candidate.partyAcronym,
          'partyColor': candidate.partyColor,
          'slogan': candidate.slogan.trim(),
          'bio': candidate.bio.trim(),
          'campaignUrl': candidate.campaignUrl.trim(),
          'avatarUrl': candidate.avatarUrl.trim(),
          'runningMate': candidate.runningMate.trim(),
        },
      );
    } catch (_) {
      final candidateRef = _firestore
          .collection('elections/$electionId/candidates')
          .doc(candidate.id);
      await candidateRef.set({
        'id': candidate.id,
        'fullName': candidate.fullName,
        'partyName': candidate.partyName,
        'partyAcronym': candidate.partyAcronym,
        'partyColor': candidate.partyColor,
        'slogan': candidate.slogan.trim(),
        'bio': candidate.bio.trim(),
        'campaignUrl': candidate.campaignUrl.trim(),
        'avatarUrl': candidate.avatarUrl.trim(),
        'runningMate': candidate.runningMate.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    final electionSnap = await _firestore.doc('elections/$electionId').get();
    final data = electionSnap.data() ?? const <String, dynamic>{};
    final candidatesSnap = await _firestore
        .collection('elections/$electionId/candidates')
        .get();
    final candidates = candidatesSnap.docs
        .map((c) => _parseCandidate({'id': c.id, ...c.data()}))
        .toList();
    return _parseElection({
      'id': electionId,
      ...data,
      'candidates': candidates,
    });
  }

  @override
  Future<void> decideRegistration({
    required String registrationId,
    required bool approve,
    String? reason,
    String? voterId,
  }) async {
    await _workerClient.post(
      '/v1/admin/registration/decide',
      data: {
        'registrationId': registrationId,
        'decision': approve ? 'approved' : 'rejected',
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        if (voterId != null && voterId.isNotEmpty) 'voterId': voterId,
      },
      allowOfflineQueue: true,
      queueType: 'admin_registration_decide',
    );
  }

  @override
  Future<List<VoterAdminRecord>> fetchVoters({
    String query = '',
    CameroonRegion? region,
    VoterStatus? status,
  }) async {
    try {
      final response = await _workerClient.get(
        '/v1/admin/voters',
        queryParameters: {
          if (region != null) 'region': region.code,
          if (status != null) 'status': _serializeVoterStatus(status),
        },
      );
      final items = response['voters'];
      if (items is! List) return const [];
      final voters = items
          .whereType<Map<String, dynamic>>()
          .map(_extractVoterData)
          .where(_isVoterRoleData)
          .map(_parseVoter)
          .toList();
      if (query.trim().isEmpty) return voters;
      final needle = query.trim().toLowerCase();
      return voters
          .where(
            (v) =>
                v.fullName.toLowerCase().contains(needle) ||
                v.voterId.toLowerCase().contains(needle),
          )
          .toList();
    } catch (_) {
      Query<Map<String, dynamic>> queryRef = _firestore.collection('users');
      if (region != null) {
        queryRef = queryRef.where('regionCode', isEqualTo: region.code);
      }
      if (status != null) {
        queryRef = queryRef.where(
          'status',
          isEqualTo: _serializeVoterStatus(status),
        );
      }
      final snap = await queryRef.get();
      final raw = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      final voters = raw.where(_isVoterRoleData).map(_parseVoter).toList();
      if (query.trim().isEmpty) return voters;
      final needle = query.trim().toLowerCase();
      return voters
          .where(
            (v) =>
                v.fullName.toLowerCase().contains(needle) ||
                v.voterId.toLowerCase().contains(needle),
          )
          .toList();
    }
  }

  @override
  Future<List<ObserverAdminRecord>> fetchObservers({String query = ''}) async {
    try {
      final response = await _workerClient.get(
        '/v1/admin/observers',
        queryParameters: query.trim().isEmpty ? null : {'q': query.trim()},
      );
      final items = response['observers'];
      if (items is! List) return const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((entry) => _parseObserver(entry))
          .toList();
    } catch (_) {
      final snap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'observer')
          .get();
      var observers = snap.docs.map((doc) {
        return _parseObserver({'id': doc.id, ...doc.data()});
      }).toList();
      final q = query.trim().toLowerCase();
      if (q.isNotEmpty) {
        observers = observers.where((o) {
          return o.uid.toLowerCase().contains(q) ||
              o.email.toLowerCase().contains(q) ||
              o.fullName.toLowerCase().contains(q);
        }).toList();
      }
      return observers;
    }
  }

  @override
  Future<ObserverAdminRecord> setObserverRole({
    required String identifier,
    required bool grant,
  }) async {
    final role = grant ? 'observer' : 'public';
    try {
      final response = await _workerClient.post(
        '/v1/admin/observers/assign',
        data: {'identifier': identifier.trim(), 'role': role},
        allowOfflineQueue: true,
        queueType: 'admin_observer_assign',
      );
      final queued = response['queued'] == true;
      if (queued) {
        return ObserverAdminRecord(
          uid: identifier.trim(),
          fullName: '',
          email: identifier.trim().contains('@') ? identifier.trim() : '',
          role: role,
          status: role == 'observer' ? 'observer' : 'public',
          mustChangePassword: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      final user = response['user'];
      if (user is Map<String, dynamic>) {
        return _parseObserver(user);
      }
      return ObserverAdminRecord(
        uid: _asString(response['uid']),
        fullName: '',
        email: '',
        role: role,
        status: role == 'observer' ? 'observer' : 'public',
        mustChangePassword: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      final trimmed = identifier.trim();
      if (trimmed.isEmpty) {
        rethrow;
      }
      if (trimmed.contains('@')) {
        final snap = await _firestore
            .collection('users')
            .where('email', isEqualTo: trimmed)
            .limit(1)
            .get();
        if (snap.docs.isEmpty) {
          rethrow;
        }
        final doc = snap.docs.first;
        await _firestore.collection('users').doc(doc.id).update({
          'role': role,
          'updatedAt': DateTime.now(),
          'roleUpdatedAt': DateTime.now(),
        });
        final fresh = await _firestore.collection('users').doc(doc.id).get();
        return _parseObserver({'id': doc.id, ...?fresh.data()});
      }
      final ref = _firestore.collection('users').doc(trimmed);
      await ref.update({
        'role': role,
        'updatedAt': DateTime.now(),
        'roleUpdatedAt': DateTime.now(),
      });
      final fresh = await ref.get();
      return _parseObserver({'id': trimmed, ...?fresh.data()});
    }
  }

  @override
  Future<ObserverAdminRecord> createObserver({
    required String fullName,
    required String email,
    required String temporaryPassword,
    String username = '',
  }) async {
    final response = await _workerClient.post(
      '/v1/admin/observers/create',
      data: {
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': temporaryPassword,
        if (username.trim().isNotEmpty) 'username': username.trim(),
      },
      allowOfflineQueue: true,
      queueType: 'admin_observer_create',
    );
    final queued = response['queued'] == true;
    if (queued) {
      return ObserverAdminRecord(
        uid: '',
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        role: 'observer',
        status: 'pending',
        mustChangePassword: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    final user =
        (response['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return _parseObserver(user);
  }

  @override
  Future<void> deleteObserver({required String identifier}) async {
    await _workerClient.post(
      '/v1/admin/observers/delete',
      data: {'identifier': identifier.trim()},
      allowOfflineQueue: true,
      queueType: 'admin_observer_delete',
    );
  }

  @override
  Future<List<VoterAdminRecord>> runElectoralListCleaning() async {
    return fetchVoters();
  }

  @override
  Future<List<AuditEvent>> fetchAuditEvents({AuditEventType? type}) async {
    try {
      final response = await _workerClient.get(
        '/v1/admin/audit-events',
        queryParameters: {if (type != null) 'type': _serializeAuditType(type)},
      );
      final items = response['events'];
      if (items is! List) return const [];
      final parsed = items
          .whereType<Map<String, dynamic>>()
          .map(_parseWorkerAuditEvent)
          .toList();
      if (type == null) return parsed;
      return parsed.where((event) => event.type == type).toList();
    } catch (_) {
      Query<Map<String, dynamic>> queryRef = _firestore
          .collection('audit_events')
          .orderBy('at', descending: true);
      if (type != null) {
        queryRef = queryRef.where('type', isEqualTo: _serializeAuditType(type));
      }
      final snap = await queryRef.get();
      return snap.docs
          .map((d) => _parseAudit({'id': d.id, ...d.data()}))
          .toList();
    }
  }

  AuditEvent _parseWorkerAuditEvent(Map<String, dynamic> raw) {
    final nested = (raw['data'] as Map?)?.cast<String, dynamic>() ?? {};
    return _parseAudit({
      ...nested,
      if (_asString(nested['id']).isEmpty) 'id': raw['id'],
      if (_asString(nested['type']).isEmpty) 'type': raw['type'],
      if (_asString(nested['message']).isEmpty) 'message': raw['message'],
      if (_asString(nested['actorRole']).isEmpty)
        'actorRole': raw['actorRole'] ?? raw['actor'],
      if (nested['at'] == null) 'at': raw['at'] ?? raw['createdAt'],
    });
  }

  Election _parseElection(Map<String, dynamic> data) {
    final candidates = _parseCandidates(data['candidates']);
    return Election(
      id: _asString(data['id']),
      title: _asString(data['title']),
      type: _parseElectionType(data['type']),
      startAt: _parseDate(data['startAt']) ?? DateTime.now(),
      endAt: _parseDate(data['endAt']) ?? DateTime.now(),
      registrationDeadline: _parseDate(
        data['registrationDeadline'] ?? data['registration_deadline'],
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

  Election _parseElectionFromWorker(Map<String, dynamic> payload) {
    final data =
        (payload['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final id = _asString(payload['id']);
    final candidates =
        (payload['candidates'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(
              (c) => _parseCandidate(
                (c['data'] as Map?)?.cast<String, dynamic>() ??
                    const <String, dynamic>{},
              ),
            )
            .toList() ??
        const <Candidate>[];
    return _parseElection({...data, 'id': id, 'candidates': candidates});
  }

  Map<String, dynamic> _extractVoterData(Map<String, dynamic> payload) {
    return (payload['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
  }

  Candidate _parseCandidate(Map<String, dynamic> data) {
    return Candidate(
      id: _asString(data['id']),
      fullName: _asString(data['fullName'] ?? data['name']),
      partyName: _asString(data['partyName'] ?? data['party']),
      partyAcronym: _asString(data['partyAcronym'] ?? data['acronym']),
      partyColor: _asInt(data['partyColor'] ?? data['color']),
      slogan: _asString(data['slogan']),
      bio: _asString(data['bio']),
      campaignUrl: _asString(data['campaignUrl']),
      avatarUrl: _asString(data['avatarUrl']),
      runningMate: _asString(data['runningMate']),
    );
  }

  ElectionType _parseElectionType(dynamic value) {
    final raw = _asString(value).toLowerCase();
    return switch (raw) {
      'presidential' => ElectionType.presidential,
      'parliamentary' => ElectionType.parliamentary,
      'municipal' => ElectionType.municipal,
      'regional' => ElectionType.regional,
      'senatorial' => ElectionType.senatorial,
      'referendum' => ElectionType.referendum,
      _ => ElectionType.presidential,
    };
  }

  String _serializeElectionType(ElectionType type) => type.name;

  VoterAdminRecord _parseVoter(Map<String, dynamic> data) {
    final dob = _parseDate(data['dob'] ?? data['dateOfBirth']);
    final age = dob == null ? 0 : _computeAge(dob);
    return VoterAdminRecord(
      voterId: _asString(data['voterId']),
      registrationId: _asString(data['registrationId']),
      registrationStatus: _asString(data['registrationStatus']),
      fullName: _asString(data['fullName']),
      region:
          _parseRegion(data['regionCode'] ?? data['region']) ??
          CameroonRegion.centre,
      age: age,
      verified: _asBool(data['verified']),
      hasVoted: _asBool(data['hasVoted']),
      status: _parseVoterStatus(data['status']),
      registeredAt:
          _parseDate(data['registeredAt'] ?? data['createdAt']) ??
          DateTime.now(),
      cardExpiry:
          _parseDate(data['cardExpiry'] ?? data['docExpiry']) ?? DateTime.now(),
      deviceFlagged: _asBool(data['deviceFlagged']),
      biometricDuplicateFlag: _asBool(data['biometricDuplicateFlag']),
    );
  }

  bool _isVoterRoleData(Map<String, dynamic> data) {
    final role = _asString(data['role']).toLowerCase();
    // Legacy records may not have role set; treat them as voter-compatible.
    return role.isEmpty || role == 'voter';
  }

  AuditEvent _parseAudit(Map<String, dynamic> data) {
    return AuditEvent(
      id: _asString(data['id']),
      type: _parseAuditType(data['type']),
      at:
          _parseDate(data['at'] ?? data['createdAt'] ?? data['created_at']) ??
          DateTime.now(),
      actorRole: _asString(data['actorRole'] ?? data['actor']),
      message: _asString(data['message']),
    );
  }

  ObserverAdminRecord _parseObserver(Map<String, dynamic> data) {
    final inner = (data['data'] as Map?)?.cast<String, dynamic>() ?? data;
    return ObserverAdminRecord(
      uid: _asString(inner['uid'] ?? data['id']),
      fullName: _asString(inner['fullName']),
      email: _asString(inner['email']),
      role: _asString(inner['role']).isEmpty
          ? 'observer'
          : _asString(inner['role']),
      status: _asString(inner['status']).isEmpty
          ? (_asString(inner['role']).isEmpty
                ? 'observer'
                : _asString(inner['role']))
          : _asString(inner['status']),
      mustChangePassword: _asBool(inner['mustChangePassword']),
      createdAt: _parseDate(inner['createdAt']) ?? DateTime.now(),
      updatedAt:
          _parseDate(inner['updatedAt'] ?? inner['roleUpdatedAt']) ??
          DateTime.now(),
    );
  }

  List<Candidate> _parseCandidates(dynamic raw) {
    if (raw is List<Candidate>) return raw;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((c) => _parseCandidate(c))
        .toList();
  }

  Map<String, int> _parseVotesMap(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, int>{};
    raw.forEach((key, value) {
      out[_asString(key)] = _asInt(value);
    });
    return out;
  }

  Map<CameroonRegion, String> _parseRegionWinners(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <CameroonRegion, String>{};
    raw.forEach((key, value) {
      final region = _parseRegion(key);
      if (region != null) {
        out[region] = _asString(value);
      }
    });
    return out;
  }

  CameroonRegion? _parseRegion(dynamic raw) {
    final code = _asString(raw).toUpperCase();
    for (final region in CameroonRegion.values) {
      if (region.code == code) return region;
    }
    return null;
  }

  VoterStatus _parseVoterStatus(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'pendingverification' => VoterStatus.pendingVerification,
      'pending_verification' => VoterStatus.pendingVerification,
      'registered' => VoterStatus.registered,
      'preeligible' => VoterStatus.preEligible,
      'pre_eligible' => VoterStatus.preEligible,
      'eligible' => VoterStatus.eligible,
      'voted' => VoterStatus.voted,
      'suspended' => VoterStatus.suspended,
      'deceased' => VoterStatus.deceased,
      'archived' => VoterStatus.archived,
      _ => VoterStatus.registered,
    };
  }

  String _serializeVoterStatus(VoterStatus status) {
    return switch (status) {
      VoterStatus.pendingVerification => 'pending_verification',
      VoterStatus.registered => 'registered',
      VoterStatus.preEligible => 'pre_eligible',
      VoterStatus.eligible => 'eligible',
      VoterStatus.voted => 'voted',
      VoterStatus.suspended => 'suspended',
      VoterStatus.deceased => 'deceased',
      VoterStatus.archived => 'archived',
    };
  }

  AuditEventType _parseAuditType(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'electioncreated' => AuditEventType.electionCreated,
      'election_created' => AuditEventType.electionCreated,
      'candidateadded' => AuditEventType.candidateAdded,
      'candidate_added' => AuditEventType.candidateAdded,
      'resultspublished' => AuditEventType.resultsPublished,
      'results_published' => AuditEventType.resultsPublished,
      'listcleaned' => AuditEventType.listCleaned,
      'list_cleaned' => AuditEventType.listCleaned,
      'registrationapproved' => AuditEventType.registrationApproved,
      'registration_approved' => AuditEventType.registrationApproved,
      'registrationrejected' => AuditEventType.registrationRejected,
      'registration_rejected' => AuditEventType.registrationRejected,
      'suspiciousactivity' => AuditEventType.suspiciousActivity,
      'suspicious_activity' => AuditEventType.suspiciousActivity,
      'devicebanned' => AuditEventType.deviceBanned,
      'device_banned' => AuditEventType.deviceBanned,
      'votecast' => AuditEventType.voteCast,
      'vote_cast' => AuditEventType.voteCast,
      'rolechanged' => AuditEventType.roleChanged,
      'role_changed' => AuditEventType.roleChanged,
      _ => AuditEventType.suspiciousActivity,
    };
  }

  String _serializeAuditType(AuditEventType type) {
    return switch (type) {
      AuditEventType.electionCreated => 'election_created',
      AuditEventType.candidateAdded => 'candidate_added',
      AuditEventType.resultsPublished => 'results_published',
      AuditEventType.listCleaned => 'list_cleaned',
      AuditEventType.registrationApproved => 'registration_approved',
      AuditEventType.registrationRejected => 'registration_rejected',
      AuditEventType.suspiciousActivity => 'suspicious_activity',
      AuditEventType.deviceBanned => 'device_banned',
      AuditEventType.voteCast => 'vote_cast',
      AuditEventType.roleChanged => 'role_changed',
    };
  }

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  bool _isUnauthorized(Object error) {
    return error is WorkerException &&
        (error.statusCode == 401 || error.statusCode == 403);
  }

  Future<AdminStats?> _tryFetchPublicStatsFallback() async {
    try {
      final response = await _workerClient.get(
        '/v1/public/electoral-stats',
        authRequired: false,
      );
      return AdminStats(
        totalRegistered: _firstNonZero([
          response['totalRegistered'],
          response['total'],
        ]),
        totalVoted: _asInt(response['totalVoted']),
        suspiciousFlags: _asInt(response['suspiciousFlags']),
        activeElections: 0,
        adminCount: 0,
        observerCount: 0,
      );
    } catch (_) {
      return null;
    }
  }

  int _firstNonZero(List<dynamic> values) {
    for (final value in values) {
      final parsed = _asInt(value);
      if (parsed > 0) return parsed;
    }
    for (final value in values) {
      if (value != null) return _asInt(value);
    }
    return 0;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    final raw = value?.toString() ?? '';
    if (raw.startsWith('0x') || raw.startsWith('0X')) {
      return int.tryParse(raw.substring(2), radix: 16) ?? 0;
    }
    return int.tryParse(raw) ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    final raw = _asString(value).toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  int _computeAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age -= 1;
    }
    return age;
  }

  VoterDemographics _computeDemographicsFromVoters(
    List<VoterAdminRecord> voters,
  ) {
    final bands = <AgeBandDistribution>[
      const AgeBandDistribution(
        key: '18_24',
        label: '18-24',
        count: 0,
        percent: 0,
      ),
      const AgeBandDistribution(
        key: '25_34',
        label: '25-34',
        count: 0,
        percent: 0,
      ),
      const AgeBandDistribution(
        key: '35_44',
        label: '35-44',
        count: 0,
        percent: 0,
      ),
      const AgeBandDistribution(
        key: '45_59',
        label: '45-59',
        count: 0,
        percent: 0,
      ),
      const AgeBandDistribution(
        key: '60_plus',
        label: '60+',
        count: 0,
        percent: 0,
      ),
    ];

    int total = 0;
    final counts = List<int>.filled(bands.length, 0);
    for (final voter in voters) {
      if (!voter.verified || voter.age < 18) continue;
      total += 1;
      if (voter.age <= 24) {
        counts[0] += 1;
      } else if (voter.age <= 34) {
        counts[1] += 1;
      } else if (voter.age <= 44) {
        counts[2] += 1;
      } else if (voter.age <= 59) {
        counts[3] += 1;
      } else {
        counts[4] += 1;
      }
    }

    double pct(int count) => total == 0 ? 0 : ((count / total) * 100);
    final resolvedBands = <AgeBandDistribution>[
      for (var i = 0; i < bands.length; i++)
        AgeBandDistribution(
          key: bands[i].key,
          label: bands[i].label,
          count: counts[i],
          percent: pct(counts[i]),
        ),
    ];

    final youthCount = counts[0] + counts[1];
    final adultCount = counts[2] + counts[3];
    final seniorCount = counts[4];

    return VoterDemographics(
      total: total,
      bands: resolvedBands,
      youth: DerivedAgeDistribution(
        count: youthCount,
        percent: pct(youthCount),
      ),
      adult: DerivedAgeDistribution(
        count: adultCount,
        percent: pct(adultCount),
      ),
      senior: DerivedAgeDistribution(
        count: seniorCount,
        percent: pct(seniorCount),
      ),
    );
  }
}
