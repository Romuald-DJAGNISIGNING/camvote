import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/network/worker_client.dart';
import '../models/tools_models.dart';

abstract class ToolsRepository {
  Future<FraudInsight> fetchFraudInsight();
  Future<List<DeviceRisk>> fetchDeviceRisks();
  Future<List<IncidentOverview>> fetchIncidentOverview({String? status});
  Future<List<ResultsPublishStatus>> fetchResultsPublishing();
  Future<void> publishResults(String electionId);
  Future<List<TransparencyUpdate>> fetchTransparencyFeed({String? localeCode});
  Future<List<ObservationChecklistItem>> fetchObservationChecklist({
    String? localeCode,
  });
  Future<void> updateChecklistItem(String itemId, bool completed);
  Future<List<IncidentOverview>> fetchObserverIncidents({String? status});
  Future<List<ElectionCalendarEntry>> fetchElectionCalendar({
    String? localeCode,
  });
  Future<List<CivicLesson>> fetchCivicLessons({String? localeCode});
}

class ApiToolsRepository implements ToolsRepository {
  ApiToolsRepository({WorkerClient? workerClient, FirebaseAuth? auth})
    : _workerClient = workerClient ?? WorkerClient(),
      _auth = auth ?? FirebaseAuth.instance;

  final WorkerClient _workerClient;
  final FirebaseAuth _auth;

  @override
  Future<FraudInsight> fetchFraudInsight() async {
    final response = await _workerClient.get('/v1/tools/fraud-insight');
    final data =
        (response['data'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return FraudInsight(
      riskScore: _asDouble(data['riskScore']),
      totalSignals: _asInt(data['totalSignals']),
      devicesFlagged: _asInt(data['devicesFlagged']),
      accountsAtRisk: _asInt(data['accountsAtRisk']),
      lastUpdated: _parseDate(data['lastUpdated']),
      signals: _parseSignals(data['signals']),
    );
  }

  @override
  Future<List<DeviceRisk>> fetchDeviceRisks() async {
    final response = await _workerClient.get('/v1/tools/device-risks');
    final items = response['risks'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseDevice({'id': doc['id'], ...data});
        })
        .toList();
  }

  @override
  Future<List<IncidentOverview>> fetchIncidentOverview({String? status}) async {
    final response = await _workerClient.get(
      '/v1/tools/incidents',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );
    final items = response['incidents'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseIncident({'id': doc['id'], ...data});
        })
        .toList();
  }

  @override
  Future<List<ResultsPublishStatus>> fetchResultsPublishing() async {
    final response = await _workerClient.get('/v1/tools/results-publishing');
    final items = response['results'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data = doc.cast<String, dynamic>();
          return ResultsPublishStatus(
            electionId: _asString(data['electionId']),
            electionTitle: _asString(data['electionTitle']),
            readyToPublish: _asBool(data['readyToPublish']),
            totalVotes: _asInt(data['totalVotes']),
            precinctsReporting: _asInt(data['precinctsReporting']),
            lastPublishedAt: _parseDate(data['lastPublishedAt']),
          );
        })
        .toList();
  }

  @override
  Future<void> publishResults(String electionId) async {
    await _workerClient.post(
      '/v1/tools/results/publish',
      data: {'electionId': electionId},
    );
  }

  @override
  Future<List<TransparencyUpdate>> fetchTransparencyFeed({
    String? localeCode,
  }) async {
    final locale = (localeCode ?? 'en').toLowerCase();
    final response = await _workerClient.get(
      '/v1/tools/transparency',
      queryParameters: {'locale': locale},
      authRequired: false,
    );
    final items = response['updates'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseTransparencyUpdate({'id': doc['id'], ...data});
        })
        .toList();
  }

  @override
  Future<List<ObservationChecklistItem>> fetchObservationChecklist({
    String? localeCode,
  }) async {
    final locale = (localeCode ?? 'en').toLowerCase();
    final response = await _workerClient.get(
      '/v1/tools/observation-checklist',
      queryParameters: {'locale': locale},
      authRequired: false,
    );
    final items = response['items'];
    if (items is! List) return const [];
    final uid = _auth.currentUser?.uid;
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseChecklistItem({'id': doc['id'], ...data}, uid);
        })
        .toList();
  }

  @override
  Future<void> updateChecklistItem(String itemId, bool completed) async {
    await _workerClient.post(
      '/v1/tools/observation-checklist/update',
      data: {'itemId': itemId, 'completed': completed},
    );
  }

  @override
  Future<List<IncidentOverview>> fetchObserverIncidents({
    String? status,
  }) async {
    final response = await _workerClient.get(
      '/v1/tools/observer-incidents',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );
    final items = response['incidents'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseIncident({'id': doc['id'], ...data});
        })
        .toList();
  }

  @override
  Future<List<ElectionCalendarEntry>> fetchElectionCalendar({
    String? localeCode,
  }) async {
    final locale = (localeCode ?? 'en').toLowerCase();
    final response = await _workerClient.get(
      '/v1/tools/election-calendar',
      queryParameters: {'locale': locale},
      authRequired: false,
    );
    final items = response['calendar'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseCalendarEntry({'id': doc['id'], ...data});
        })
        .toList();
  }

  @override
  Future<List<CivicLesson>> fetchCivicLessons({String? localeCode}) async {
    final locale = (localeCode ?? 'en').toLowerCase();
    final response = await _workerClient.get(
      '/v1/tools/civic-lessons',
      queryParameters: {'locale': locale},
      authRequired: false,
    );
    final items = response['lessons'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return _parseLesson({'id': doc['id'], ...data});
        })
        .toList();
  }

  List<FraudSignal> _parseSignals(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => FraudSignal(
            id: _asString(item['id']),
            title: _asString(item['title']),
            detail: _asString(item['detail']),
            count: _asInt(item['count']),
            severity: _asString(item['severity'] ?? item['level']),
          ),
        )
        .toList();
  }

  DeviceRisk _parseDevice(Map<String, dynamic> data) {
    return DeviceRisk(
      deviceId: _asString(data['deviceId'] ?? data['id']),
      label: _asString(data['label'] ?? data['model']),
      reason: _asString(data['reason']),
      status: _asString(data['status']),
      strikes: _asInt(data['strikes']),
      lastSeen: _parseDate(data['lastSeen']),
    );
  }

  IncidentOverview _parseIncident(Map<String, dynamic> data) {
    final attachments = data['attachments'];
    return IncidentOverview(
      id: _asString(data['id']),
      title: _asString(data['title'] ?? data['category']),
      status: _asString(data['status']),
      severity: _asString(data['severity']),
      location: _asString(data['location']),
      reportedAt:
          _parseDate(
            data['reportedAt'] ?? data['occurredAt'] ?? data['createdAt'],
          ) ??
          DateTime.now(),
      reporterRole: _asString(data['reporterRole'] ?? data['role']),
      attachments: attachments is List
          ? attachments
                .map((a) => _asString(a))
                .where((a) => a.isNotEmpty)
                .toList()
          : const [],
    );
  }

  TransparencyUpdate _parseTransparencyUpdate(Map<String, dynamic> data) {
    return TransparencyUpdate(
      id: _asString(data['id']),
      title: _asString(data['title']),
      summary: _asString(data['summary']),
      publishedAt: _parseDate(data['publishedAt']) ?? DateTime.now(),
      source: _asString(data['source']),
    );
  }

  ObservationChecklistItem _parseChecklistItem(
    Map<String, dynamic> data,
    String? uid,
  ) {
    final completedBy = data['completedBy'];
    final isCompleted =
        _asBool(data['completed']) ||
        (uid != null &&
            completedBy is List &&
            completedBy.map((e) => e.toString()).contains(uid));
    return ObservationChecklistItem(
      id: _asString(data['id']),
      title: _asString(data['title']),
      description: _asString(data['description']),
      required: _asBool(data['required']),
      completed: isCompleted,
    );
  }

  CivicLesson _parseLesson(Map<String, dynamic> data) {
    return CivicLesson(
      id: _asString(data['id']),
      title: _asString(data['title']),
      summary: _asString(data['summary']),
      category: _asString(data['category']),
      sourceUrl: _asString(data['sourceUrl'] ?? data['source_url']),
    );
  }

  ElectionCalendarEntry _parseCalendarEntry(Map<String, dynamic> data) {
    return ElectionCalendarEntry(
      id: _asString(data['id']),
      title: _asString(data['title']),
      scope: _asString(data['scope']),
      location: _asString(data['location']),
      status: _asString(data['status']),
      startAt: _parseDate(data['startAt']) ?? DateTime.now(),
      endAt: _parseDate(data['endAt']) ?? DateTime.now(),
    );
  }

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
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
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    return DateTime.tryParse(value.toString());
  }
}
