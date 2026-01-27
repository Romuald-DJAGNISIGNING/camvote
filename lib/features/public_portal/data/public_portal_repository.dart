import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../models/public_models.dart';

class PublicPortalRepository {
  PublicPortalRepository(this._dio);

  final Dio _dio;

  Future<PublicResultsState> fetchResults() async {
    _ensureApiConfigured();
    final res = await _dio.get('/public/results');
    final data = _asMap(res.data);

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

  Future<PublicVoterLookupResult> lookupVoter({
    required String regNumber,
    required DateTime dob,
  }) async {
    _ensureApiConfigured();
    final res = await _dio.post(
      '/public/verify',
      data: {
        'registrationNumber': regNumber,
        'dateOfBirth': dob.toIso8601String(),
      },
    );
    final data = _asMap(res.data);
    final status = _parseStatus(data['status']);

    return PublicVoterLookupResult(
      status: status,
      maskedName: _asString(data['maskedName']),
      maskedRegNumber: _asString(data['maskedRegNumber']),
      cardExpiry: _parseDate(data['cardExpiry']),
    );
  }

  void _ensureApiConfigured() {
    if (!AppConfig.hasApiBaseUrl) {
      throw StateError('API base URL is not configured.');
    }
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
              percent: c.percent > 0
                  ? c.percent
                  : (c.votes / totalVotes) * 100,
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
      final winnerName =
          _asString(item['winnerName'] ?? item['candidateName']);
      list.add(
        RegionalWinner(
          regionCode: _asString(item['regionCode'] ?? item['region']),
          winnerName: winnerName,
          winnerColor:
              _parseColor(item['winnerColor'], winnerName, candidates),
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

  PublicVoterLookupStatus _parseStatus(dynamic raw) {
    final value = _asString(raw).toLowerCase();
    return switch (value) {
      'pending' || 'pending_verification' => PublicVoterLookupStatus.pendingVerification,
      'registered_pre_eligible' || 'pre_eligible' => PublicVoterLookupStatus.registeredPreEligible,
      'eligible' => PublicVoterLookupStatus.eligible,
      'voted' => PublicVoterLookupStatus.voted,
      'suspended' => PublicVoterLookupStatus.suspended,
      'deceased' => PublicVoterLookupStatus.deceased,
      'archived' => PublicVoterLookupStatus.archived,
      _ => PublicVoterLookupStatus.notFound,
    };
  }

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
}
