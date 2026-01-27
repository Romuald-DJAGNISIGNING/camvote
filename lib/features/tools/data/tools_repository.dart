import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../models/tools_models.dart';

abstract class ToolsRepository {
  Future<FraudInsight> fetchFraudInsight();
  Future<List<DeviceRisk>> fetchDeviceRisks();
  Future<List<IncidentOverview>> fetchIncidentOverview({String? status});
  Future<List<ResultsPublishStatus>> fetchResultsPublishing();
  Future<void> publishResults(String electionId);
  Future<List<TransparencyUpdate>> fetchTransparencyFeed();
  Future<List<ObservationChecklistItem>> fetchObservationChecklist();
  Future<void> updateChecklistItem(String itemId, bool completed);
  Future<List<IncidentOverview>> fetchObserverIncidents({String? status});
  Future<List<ElectionCalendarEntry>> fetchElectionCalendar();
  Future<List<CivicLesson>> fetchCivicLessons();
}

class ApiToolsRepository implements ToolsRepository {
  ApiToolsRepository(this._dio);

  final Dio _dio;

  void _ensureApiConfigured() {
    if (!AppConfig.hasApiBaseUrl) {
      throw StateError('API base URL is not configured.');
    }
  }

  @override
  Future<FraudInsight> fetchFraudInsight() async {
    _ensureApiConfigured();
    final res = await _dio.get('/admin/fraud/insights');
    final data = _asMap(res.data);
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
    _ensureApiConfigured();
    final res = await _dio.get('/admin/security/devices');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseDevice).toList();
  }

  @override
  Future<List<IncidentOverview>> fetchIncidentOverview({String? status}) async {
    _ensureApiConfigured();
    final res = await _dio.get(
      '/admin/incidents',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );
    return _parseIncidents(res.data);
  }

  @override
  Future<List<ResultsPublishStatus>> fetchResultsPublishing() async {
    _ensureApiConfigured();
    final res = await _dio.get('/admin/results/publishing');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_parsePublishStatus)
        .toList();
  }

  @override
  Future<void> publishResults(String electionId) async {
    _ensureApiConfigured();
    await _dio.post('/admin/results/$electionId/publish');
  }

  @override
  Future<List<TransparencyUpdate>> fetchTransparencyFeed() async {
    _ensureApiConfigured();
    final res = await _dio.get('/observer/transparency-feed');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_parseTransparencyUpdate)
        .toList();
  }

  @override
  Future<List<ObservationChecklistItem>> fetchObservationChecklist() async {
    _ensureApiConfigured();
    final res = await _dio.get('/observer/observation-checklist');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_parseChecklistItem)
        .toList();
  }

  @override
  Future<void> updateChecklistItem(String itemId, bool completed) async {
    _ensureApiConfigured();
    await _dio.post(
      '/observer/observation-checklist/$itemId',
      data: {'completed': completed},
    );
  }

  @override
  Future<List<IncidentOverview>> fetchObserverIncidents(
      {String? status}) async {
    _ensureApiConfigured();
    final res = await _dio.get(
      '/observer/incidents',
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status,
      },
    );
    return _parseIncidents(res.data);
  }

  @override
  Future<List<ElectionCalendarEntry>> fetchElectionCalendar() async {
    _ensureApiConfigured();
    final res = await _dio.get('/public/election-calendar');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_parseCalendarEntry)
        .toList();
  }

  @override
  Future<List<CivicLesson>> fetchCivicLessons() async {
    _ensureApiConfigured();
    final res = await _dio.get('/public/civic-education');
    final raw = res.data;
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseLesson).toList();
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

  List<IncidentOverview> _parseIncidents(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().map(_parseIncident).toList();
  }

  IncidentOverview _parseIncident(Map<String, dynamic> data) {
    final attachments = data['attachments'];
    return IncidentOverview(
      id: _asString(data['id']),
      title: _asString(data['title'] ?? data['category']),
      status: _asString(data['status']),
      severity: _asString(data['severity']),
      location: _asString(data['location']),
      reportedAt: _parseDate(data['reportedAt']) ?? DateTime.now(),
      reporterRole: _asString(data['reporterRole'] ?? data['role']),
      attachments: attachments is List
          ? attachments.map((a) => _asString(a)).where((a) => a.isNotEmpty).toList()
          : const [],
    );
  }

  ResultsPublishStatus _parsePublishStatus(Map<String, dynamic> data) {
    return ResultsPublishStatus(
      electionId: _asString(data['electionId'] ?? data['id']),
      electionTitle: _asString(data['electionTitle'] ?? data['title']),
      readyToPublish: _asBool(data['readyToPublish']),
      totalVotes: _asInt(data['totalVotes']),
      precinctsReporting: _asInt(data['precinctsReporting']),
      lastPublishedAt: _parseDate(data['lastPublishedAt']),
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

  ObservationChecklistItem _parseChecklistItem(Map<String, dynamic> data) {
    return ObservationChecklistItem(
      id: _asString(data['id']),
      title: _asString(data['title']),
      description: _asString(data['description']),
      required: _asBool(data['required']),
      completed: _asBool(data['completed']),
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

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const {};
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
    return DateTime.tryParse(value.toString());
  }
}
