import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../data/voter_elections_repository.dart';
import '../domain/election.dart';
import '../domain/vote_receipt.dart';

/// Bottom tab index
final voterTabIndexProvider =
    NotifierProvider<VoterTabIndexController, int>(
  VoterTabIndexController.new,
);

class VoterTabIndexController extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int value) => state = value;
}

/// Elections source (API)
final voterElectionsRepositoryProvider = Provider<VoterElectionsRepository>(
  (ref) => ApiVoterElectionsRepository(ref.watch(dioProvider)),
);

/// Load elections
final voterElectionsProvider = FutureProvider<List<Election>>((ref) async {
  final repo = ref.watch(voterElectionsRepositoryProvider);
  return repo.fetchAll();
});

/// One-person-one-vote local enforcement with persistence.
final votedElectionIdsProvider =
    NotifierProvider<VotedElectionIdsController, Set<String>>(
  VotedElectionIdsController.new,
);

class VotedElectionIdsController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return const <String>{};
  }

  Future<void> _load() async {
    final prefs = await ref.read(_prefsProvider.future);
    final list = prefs.getStringList('voted_election_ids') ?? <String>[];
    state = list.toSet();
  }

  bool hasVoted(String electionId) => state.contains(electionId);

  Future<void> markVoted(String electionId) async {
    state = <String>{...state, electionId};
    final prefs = await ref.read(_prefsProvider.future);
    await prefs.setStringList('voted_election_ids', state.toList());
  }
}

const _kVoteReceiptsKey = 'vote_receipts';

final _prefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final voteReceiptsProvider =
    NotifierProvider<VoteReceiptsController, List<VoteReceipt>>(
  VoteReceiptsController.new,
);

class VoteReceiptsController extends Notifier<List<VoteReceipt>> {
  @override
  List<VoteReceipt> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final prefs = await ref.read(_prefsProvider.future);
    final raw = prefs.getString(_kVoteReceiptsKey);
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return;
    final list = decoded
        .whereType<Map<String, dynamic>>()
        .map(VoteReceipt.fromJson)
        .toList();
    state = list;
  }

  Future<void> addReceipt(VoteReceipt receipt) async {
    state = [receipt, ...state];
    await _persist();
  }

  Future<void> clear() async {
    state = const [];
    final prefs = await ref.read(_prefsProvider.future);
    await prefs.remove(_kVoteReceiptsKey);
  }

  Future<void> _persist() async {
    final prefs = await ref.read(_prefsProvider.future);
    final raw = jsonEncode(state.map((r) => r.toJson()).toList());
    await prefs.setString(_kVoteReceiptsKey, raw);
  }
}
