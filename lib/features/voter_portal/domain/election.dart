import 'package:flutter/foundation.dart';

enum ElectionType {
  presidential,
  parliamentary,
  municipal,
  regional,
  senatorial,
  referendum,
}

enum ElectionStatus { upcoming, open, closed }

@immutable
class Candidate {
  final String id;
  final String fullName;
  final String partyName;
  final String partyAcronym;

  const Candidate({
    required this.id,
    required this.fullName,
    required this.partyName,
    required this.partyAcronym,
  });
}

@immutable
class Election {
  final String id;
  final ElectionType type;
  final String title;
  final DateTime opensAt;
  final DateTime closesAt;

  /// For national elections, keep this as "Cameroon".
  /// For regional breakdown, we’ll extend later.
  final String scopeLabel;

  final List<Candidate> candidates;

  const Election({
    required this.id,
    required this.type,
    required this.title,
    required this.opensAt,
    required this.closesAt,
    required this.scopeLabel,
    required this.candidates,
  });

  ElectionStatus get status {
    final now = DateTime.now();
    if (now.isBefore(opensAt)) return ElectionStatus.upcoming;
    if (now.isAfter(closesAt)) return ElectionStatus.closed;
    return ElectionStatus.open;
  }

  Duration get timeUntilOpen => opensAt.difference(DateTime.now());
  Duration get timeUntilClose => closesAt.difference(DateTime.now());
}