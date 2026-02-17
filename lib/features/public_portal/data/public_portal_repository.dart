import 'package:flutter/material.dart';
import '../../../core/network/worker_client.dart';

import '../models/public_models.dart';

class PublicPortalRepository {
  PublicPortalRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Future<PublicResultsState> fetchResults() async {
    final response = await _workerClient.get(
      '/v1/public/results',
      authRequired: false,
    );
    final data =
        (response['data'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};

    final candidates = _parseCandidates(data['candidates']);
    final regions = _parseRegionalWinners(data['regions'], candidates);
    final trend = _parseTrend(data['turnoutTrend']);

    return PublicResultsState(
      electionTitle: _asString(data['electionTitle'] ?? data['title']),
      electionClosed: _asBool(data['electionClosed']),
      lastUpdated: _parseDate(data['lastUpdated']),
      totalRegistered: _asInt(data['totalRegistered']),
      totalVotesCast: _asInt(data['totalVotesCast']),
      candidates: candidates,
      regionalWinners: regions,
      turnoutTrend: trend,
    );
  }

  Future<PublicElectoralStats> fetchElectoralStats() async {
    try {
      final response = await _workerClient.get(
        '/v1/public/electoral-stats',
        authRequired: false,
      );

      final rawBands = response['bands'];
      final bands = <PublicAgeBandDistribution>[];
      if (rawBands is List) {
        for (final raw in rawBands.whereType<Map<String, dynamic>>()) {
          bands.add(
            PublicAgeBandDistribution(
              key: _asString(raw['key']),
              label: _asString(raw['label']),
              count: _asInt(raw['count']),
              percent: _asDouble(raw['percent']),
            ),
          );
        }
      }

      final derived = response['derived'] is Map<String, dynamic>
          ? response['derived'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final youth = derived['youth'] is Map<String, dynamic>
          ? derived['youth'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final adult = derived['adult'] is Map<String, dynamic>
          ? derived['adult'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final senior = derived['senior'] is Map<String, dynamic>
          ? derived['senior'] as Map<String, dynamic>
          : const <String, dynamic>{};

      return PublicElectoralStats(
        totalRegistered: _firstNonZero([
          response['totalRegistered'],
          response['total'],
        ]),
        totalVoted: _asInt(response['totalVoted']),
        totalDeceased: _asInt(response['totalDeceased']),
        bands: bands,
        youth: PublicDerivedAgeDistribution(
          count: _asInt(youth['count']),
          percent: _asDouble(youth['percent']),
        ),
        adult: PublicDerivedAgeDistribution(
          count: _asInt(adult['count']),
          percent: _asDouble(adult['percent']),
        ),
        senior: PublicDerivedAgeDistribution(
          count: _asInt(senior['count']),
          percent: _asDouble(senior['percent']),
        ),
      );
    } catch (_) {
      final fallbackResults = await fetchResults();
      return PublicElectoralStats(
        totalRegistered: fallbackResults.totalRegistered,
        totalVoted: fallbackResults.totalVotesCast,
        totalDeceased: 0,
        bands: const <PublicAgeBandDistribution>[],
        youth: const PublicDerivedAgeDistribution(count: 0, percent: 0),
        adult: const PublicDerivedAgeDistribution(count: 0, percent: 0),
        senior: const PublicDerivedAgeDistribution(count: 0, percent: 0),
      );
    }
  }

  Future<PublicVoterLookupResult> lookupVoter({
    required String regNumber,
    required DateTime dob,
  }) async {
    final response = await _workerClient.post(
      '/v1/public/voter-lookup',
      data: {'regNumber': regNumber, 'dob': dob.toIso8601String()},
      authRequired: false,
    );
    final statusRaw = _asString(response['status']);
    final status = switch (statusRaw) {
      'eligible' => PublicVoterLookupStatus.eligible,
      'pending_verification' => PublicVoterLookupStatus.pendingVerification,
      _ => PublicVoterLookupStatus.notFound,
    };
    return PublicVoterLookupResult(
      status: status,
      maskedName: _asString(response['maskedName']),
      maskedRegNumber: _asString(response['maskedRegNumber']).isNotEmpty
          ? _asString(response['maskedRegNumber'])
          : _maskReg(regNumber),
      cardExpiry: _parseDate(response['cardExpiry']),
    );
  }

  Future<PublicElectionsInfoState?> fetchElectionsInfo({
    String? localeCode,
  }) async {
    final response = await _workerClient.get(
      '/v1/public/elections-info',
      queryParameters: {'locale': (localeCode ?? 'en').toLowerCase()},
      authRequired: false,
    );
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    final locale = (localeCode ?? 'en').toLowerCase();
    return PublicElectionsInfoState(
      title: _localized(data, 'title', locale),
      subtitle: _localized(data, 'subtitle', locale),
      sections: _parseInfoSections(data['sections'], locale),
      guidelines: _parseInfoGuidelines(data['guidelines'], locale),
      lastUpdated: _parseDate(data['lastUpdated']),
    );
  }

  List<CandidateLiveResult> _parseCandidates(dynamic raw) {
    if (raw is! List) return const [];
    final list = <CandidateLiveResult>[];
    int totalVotes = 0;

    for (final item in raw.whereType<Map<String, dynamic>>()) {
      final votes = _asInt(item['votes']);
      totalVotes += votes;
      list.add(
        CandidateLiveResult(
          candidateId: _asString(item['candidateId'] ?? item['id']),
          candidateName: _asString(item['candidateName'] ?? item['name']),
          partyName: _asString(item['partyName'] ?? item['party']),
          votes: votes,
          percent: _asDouble(item['percent']),
        ),
      );
    }

    if (totalVotes > 0) {
      return list
          .map(
            (c) => CandidateLiveResult(
              candidateId: c.candidateId,
              candidateName: c.candidateName,
              partyName: c.partyName,
              votes: c.votes,
              percent: c.percent > 0 ? c.percent : (c.votes / totalVotes) * 100,
            ),
          )
          .toList();
    }

    return list;
  }

  List<RegionalWinner> _parseRegionalWinners(
    dynamic raw,
    List<CandidateLiveResult> candidates,
  ) {
    if (raw is! List) return const [];
    final list = <RegionalWinner>[];

    for (final item in raw.whereType<Map<String, dynamic>>()) {
      final winnerName = _asString(item['winnerName'] ?? item['candidateName']);
      list.add(
        RegionalWinner(
          regionCode: _asString(item['regionCode'] ?? item['region']),
          winnerName: winnerName,
          winnerColor: _parseColor(item['winnerColor'], winnerName, candidates),
          totalVotesInRegion: _asInt(item['totalVotes'] ?? item['regionVotes']),
          winnerVotesInRegion: _asInt(item['winnerVotes']),
        ),
      );
    }

    return list;
  }

  List<double> _parseTrend(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((v) => _asDouble(v)).where((v) => v > 0).toList();
  }

  List<PublicElectionsInfoSection> _parseInfoSections(
    dynamic raw,
    String locale,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => PublicElectionsInfoSection(
            id: _asString(item['id']),
            title: _localized(item, 'title', locale),
            body: _localized(item, 'body', locale),
            sourceUrl: _asString(item['sourceUrl'] ?? item['source_url']),
            sourceLabel: _asString(item['sourceLabel'] ?? item['source_label']),
          ),
        )
        .toList();
  }

  List<PublicElectionsInfoGuideline> _parseInfoGuidelines(
    dynamic raw,
    String locale,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => PublicElectionsInfoGuideline(
            text: _localized(item, 'text', locale),
            sourceUrl: _asString(item['sourceUrl'] ?? item['source_url']),
            sourceLabel: _asString(item['sourceLabel'] ?? item['source_label']),
          ),
        )
        .toList();
  }

  String _asString(dynamic value) => value?.toString().trim() ?? '';

  String _localized(Map<String, dynamic> data, String key, String locale) {
    final localizedKey = '${key}_$locale';
    final localized = _asString(data[localizedKey]);
    if (localized.isNotEmpty) return localized;
    return _asString(data[key]);
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  int _firstNonZero(List<dynamic> values) {
    for (final value in values) {
      final parsed = _asInt(value);
      if (parsed > 0) return parsed;
    }
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    }
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  Color _parseColor(
    dynamic value,
    String winnerName,
    List<CandidateLiveResult> candidates,
  ) {
    if (value is int) return Color(value);
    if (value is String) {
      final hex = value.replaceAll('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }

    final fromCandidate = candidates.firstWhere(
      (c) => c.candidateName == winnerName,
      orElse: () => const CandidateLiveResult(
        candidateId: '',
        candidateName: '',
        partyName: '',
        votes: 0,
        percent: 0,
      ),
    );

    if (fromCandidate.candidateName.isNotEmpty) {
      return _colorFromName(fromCandidate.candidateName);
    }
    return _colorFromName(winnerName);
  }

  Color _colorFromName(String name) {
    final palette = [
      const Color(0xFF0A7D2E),
      const Color(0xFFC62828),
      const Color(0xFFF9A825),
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
    ];
    if (name.trim().isEmpty) return palette.first;
    final idx = name.hashCode.abs() % palette.length;
    return palette[idx];
  }

  String _maskReg(String reg) {
    if (reg.length <= 4) return '****';
    final start = reg.substring(0, 2);
    final end = reg.substring(reg.length - 2);
    return '$start****$end';
  }
}
