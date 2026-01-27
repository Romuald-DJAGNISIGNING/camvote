import 'package:flutter/foundation.dart';

/// Cameroon’s 10 regions (for map + stats)
enum CameroonRegion {
  adamawa,
  centre,
  east,
  farNorth,
  littoral,
  north,
  northWest,
  south,
  southWest,
  west,
}

extension CameroonRegionX on CameroonRegion {
  String get code => switch (this) {
        CameroonRegion.adamawa => 'AD',
        CameroonRegion.centre => 'CE',
        CameroonRegion.east => 'ES',
        CameroonRegion.farNorth => 'EN',
        CameroonRegion.littoral => 'LT',
        CameroonRegion.north => 'NO',
        CameroonRegion.northWest => 'NW',
        CameroonRegion.south => 'SU',
        CameroonRegion.southWest => 'SW',
        CameroonRegion.west => 'OU',
      };

  String get label => switch (this) {
        CameroonRegion.adamawa => 'Adamawa',
        CameroonRegion.centre => 'Centre',
        CameroonRegion.east => 'East',
        CameroonRegion.farNorth => 'Far North',
        CameroonRegion.littoral => 'Littoral',
        CameroonRegion.north => 'North',
        CameroonRegion.northWest => 'North West',
        CameroonRegion.south => 'South',
        CameroonRegion.southWest => 'South West',
        CameroonRegion.west => 'West',
      };
}

/// Core election types (admin creates them)
enum ElectionType {
  presidential,
  parliamentary,
  municipal,
  regional,
  senatorial,
  referendum,
}

extension ElectionTypeX on ElectionType {
  String get label => switch (this) {
        ElectionType.presidential => 'Presidential',
        ElectionType.parliamentary => 'Parliamentary',
        ElectionType.municipal => 'Municipal',
        ElectionType.regional => 'Regional',
        ElectionType.senatorial => 'Senatorial',
        ElectionType.referendum => 'Referendum',
      };
}

/// Candidate/party info (frontend model)
@immutable
class Candidate {
  final String id;
  final String fullName;
  final String partyName;
  final String partyAcronym;

  /// Use a deterministic color for charts (ARGB int like 0xFF00AA00)
  final int partyColor;
  final String slogan;
  final String bio;
  final String campaignUrl;
  final String avatarUrl;
  final String runningMate;

  const Candidate({
    required this.id,
    required this.fullName,
    required this.partyName,
    required this.partyAcronym,
    required this.partyColor,
    this.slogan = '',
    this.bio = '',
    this.campaignUrl = '',
    this.avatarUrl = '',
    this.runningMate = '',
  });
}

@immutable
class Election {
  final String id;
  final String title;
  final ElectionType type;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? registrationDeadline;
  final String description;
  final String scope;
  final String location;
  final String timezone;
  final String ballotType;
  final String eligibility;

  /// Candidates participating
  final List<Candidate> candidates;

  /// Votes by candidateId.
  final Map<String, int> votesByCandidateId;

  /// Winning party acronym per region for Cameroon map coloring
  final Map<CameroonRegion, String> winningPartyByRegion;

  const Election({
    required this.id,
    required this.title,
    required this.type,
    required this.startAt,
    required this.endAt,
    this.registrationDeadline,
    this.description = '',
    this.scope = '',
    this.location = '',
    this.timezone = '',
    this.ballotType = '',
    this.eligibility = '',
    required this.candidates,
    required this.votesByCandidateId,
    required this.winningPartyByRegion,
  });

  bool get isClosed => DateTime.now().isAfter(endAt);

  int get totalVotes => votesByCandidateId.values.fold<int>(0, (a, b) => a + b);
}

enum VoterStatus {
  pendingVerification,
  registered, // on list, 18+
  preEligible, // 18–20 (registered but cannot vote)
  eligible, // 21+
  voted,
  suspended,
  deceased,
  archived,
}

extension VoterStatusX on VoterStatus {
  String get label => switch (this) {
        VoterStatus.pendingVerification => 'Pending verification',
        VoterStatus.registered => 'Registered',
        VoterStatus.preEligible => 'Pre-eligible (18–20)',
        VoterStatus.eligible => 'Eligible (21+)',
        VoterStatus.voted => 'Voted',
        VoterStatus.suspended => 'Suspended',
        VoterStatus.deceased => 'Deceased',
        VoterStatus.archived => 'Archived',
      };
}

@immutable
class VoterAdminRecord {
  final String voterId;
  final String fullName;
  final CameroonRegion region;
  final int age;
  final bool verified;
  final bool hasVoted;
  final VoterStatus status;
  final DateTime registeredAt;
  final DateTime cardExpiry;

  /// Flags (device+biometric anti-fraud hooks)
  final bool deviceFlagged;
  final bool biometricDuplicateFlag;

  const VoterAdminRecord({
    required this.voterId,
    required this.fullName,
    required this.region,
    required this.age,
    required this.verified,
    required this.hasVoted,
    required this.status,
    required this.registeredAt,
    required this.cardExpiry,
    required this.deviceFlagged,
    required this.biometricDuplicateFlag,
  });
}

enum AuditEventType {
  electionCreated,
  candidateAdded,
  resultsPublished,
  listCleaned,
  registrationRejected,
  suspiciousActivity,
  deviceBanned,
  voteCast,
}

@immutable
class AuditEvent {
  final String id;
  final AuditEventType type;
  final DateTime at;
  final String actorRole; // "admin" / "observer" / "system"
  final String message;

  const AuditEvent({
    required this.id,
    required this.type,
    required this.at,
    required this.actorRole,
    required this.message,
  });
}

@immutable
class AdminStats {
  final int totalRegistered;
  final int totalVoted;
  final int suspiciousFlags;
  final int activeElections;

  const AdminStats({
    required this.totalRegistered,
    required this.totalVoted,
    required this.suspiciousFlags,
    required this.activeElections,
  });

  double turnoutRate() {
    if (totalRegistered == 0) return 0;
    return (totalVoted / totalRegistered) * 100;
  }
}
