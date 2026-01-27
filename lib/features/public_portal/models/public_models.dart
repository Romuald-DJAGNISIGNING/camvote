import 'package:flutter/material.dart';

class CandidateLiveResult {
  final String candidateId;
  final String candidateName;
  final String partyName;
  final int votes;
  final double percent;

  const CandidateLiveResult({
    required this.candidateId,
    required this.candidateName,
    required this.partyName,
    required this.votes,
    required this.percent,
  });
}

class RegionalWinner {
  const RegionalWinner({
    required this.regionCode,
    required this.winnerName,
    required this.winnerColor,
    required this.totalVotesInRegion,
    required this.winnerVotesInRegion,
  });

  final String regionCode;
  final String winnerName;
  final Color winnerColor;
  final int totalVotesInRegion;
  final int winnerVotesInRegion;
}

class PublicResultsState {
  final String electionTitle;
  final bool electionClosed;
  final DateTime? lastUpdated;
  final int totalRegistered;
  final int totalVotesCast;
  final List<CandidateLiveResult> candidates;
  final List<RegionalWinner> regionalWinners;
  final List<double> turnoutTrend;

  const PublicResultsState({
    required this.electionTitle,
    required this.electionClosed,
    required this.lastUpdated,
    required this.totalRegistered,
    required this.totalVotesCast,
    required this.candidates,
    required this.regionalWinners,
    required this.turnoutTrend,
  });

  int get absentee => totalRegistered - totalVotesCast;

  double get turnoutRate =>
      totalRegistered == 0 ? 0 : (totalVotesCast / totalRegistered) * 100;

  int get totalCandidateVotes =>
      candidates.fold(0, (sum, c) => sum + c.votes);
}

enum PublicVoterLookupStatus {
  notFound,
  pendingVerification,
  registeredPreEligible, // 18–20
  eligible, // 21+
  voted,
  suspended,
  deceased,
  archived,
}

class PublicVoterLookupResult {
  final PublicVoterLookupStatus status;
  final String maskedName;
  final String maskedRegNumber;
  final DateTime? cardExpiry;

  const PublicVoterLookupResult({
    required this.status,
    required this.maskedName,
    required this.maskedRegNumber,
    required this.cardExpiry,
  });
}
