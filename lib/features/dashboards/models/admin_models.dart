import 'package:flutter/foundation.dart';
import 'package:camvote/gen/l10n/app_localizations.dart';

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

  String label(AppLocalizations t) => switch (this) {
    CameroonRegion.adamawa => t.regionAdamawa,
    CameroonRegion.centre => t.regionCentre,
    CameroonRegion.east => t.regionEast,
    CameroonRegion.farNorth => t.regionFarNorth,
    CameroonRegion.littoral => t.regionLittoral,
    CameroonRegion.north => t.regionNorth,
    CameroonRegion.northWest => t.regionNorthWest,
    CameroonRegion.south => t.regionSouth,
    CameroonRegion.southWest => t.regionSouthWest,
    CameroonRegion.west => t.regionWest,
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
  String label(AppLocalizations t) => switch (this) {
    ElectionType.presidential => t.electionTypePresidential,
    ElectionType.parliamentary => t.electionTypeParliamentary,
    ElectionType.municipal => t.electionTypeMunicipal,
    ElectionType.regional => t.electionTypeRegional,
    ElectionType.senatorial => t.electionTypeSenatorial,
    ElectionType.referendum => t.electionTypeReferendum,
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
  final DateTime? campaignStartsAt;
  final DateTime? campaignEndsAt;
  final DateTime? resultsPublishAt;
  final DateTime? runoffOpensAt;
  final DateTime? runoffClosesAt;
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
    this.campaignStartsAt,
    this.campaignEndsAt,
    this.resultsPublishAt,
    this.runoffOpensAt,
    this.runoffClosesAt,
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
  String label(AppLocalizations t) => switch (this) {
    VoterStatus.pendingVerification => t.statusPendingVerification,
    VoterStatus.registered => t.statusRegistered,
    VoterStatus.preEligible => t.statusPreEligible,
    VoterStatus.eligible => t.statusEligible,
    VoterStatus.voted => t.statusVoted,
    VoterStatus.suspended => t.statusSuspended,
    VoterStatus.deceased => t.statusDeceased,
    VoterStatus.archived => t.statusArchived,
  };
}

@immutable
class VoterAdminRecord {
  final String voterId;
  final String? registrationId;
  final String? registrationStatus;
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
    this.registrationId,
    this.registrationStatus,
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

@immutable
class ObserverAdminRecord {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final bool mustChangePassword;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ObserverAdminRecord({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.mustChangePassword,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum AuditEventType {
  electionCreated,
  candidateAdded,
  resultsPublished,
  listCleaned,
  registrationApproved,
  registrationRejected,
  suspiciousActivity,
  deviceBanned,
  voteCast,
  roleChanged,
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
