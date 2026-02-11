import 'package:flutter/foundation.dart';

@immutable
class VoteReceipt {
  final String id;
  final String electionId;
  final String electionTitle;
  final String candidateHash;
  final String partyHash;
  final String auditToken;
  final DateTime castAt;

  const VoteReceipt({
    required this.id,
    required this.electionId,
    required this.electionTitle,
    required this.candidateHash,
    required this.partyHash,
    required this.auditToken,
    required this.castAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'election_id': electionId,
    'election_title': electionTitle,
    'candidate_hash': candidateHash,
    'party_hash': partyHash,
    'audit_token': auditToken,
    'cast_at': castAt.toIso8601String(),
  };

  factory VoteReceipt.fromJson(Map<String, dynamic> json) {
    return VoteReceipt(
      id: (json['id'] as String?) ?? '',
      electionId: (json['election_id'] as String?) ?? '',
      electionTitle: (json['election_title'] as String?) ?? '',
      candidateHash: (json['candidate_hash'] as String?) ?? '',
      partyHash: (json['party_hash'] as String?) ?? '',
      auditToken: (json['audit_token'] as String?) ?? '',
      castAt:
          DateTime.tryParse((json['cast_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
