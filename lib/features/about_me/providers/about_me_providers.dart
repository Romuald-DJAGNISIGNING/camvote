import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/about_repository.dart';
import '../data/trello_repository.dart';
import '../models/about_profile.dart';
import '../models/trello_stats.dart';

final aboutRepositoryProvider = Provider<AboutRepository>((ref) {
  return AboutRepository();
});

final aboutProfileProvider = FutureProvider<AboutProfile?>((ref) async {
  final repo = ref.watch(aboutRepositoryProvider);
  return repo.fetchProfile();
});

final trelloRepositoryProvider = Provider<TrelloRepository>((ref) {
  return TrelloRepository();
});

final trelloRefreshTickProvider = StreamProvider<int>((ref) async* {
  var tick = 0;
  yield tick;
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 45));
    tick += 1;
    yield tick;
  }
});

final trelloStatsProvider = FutureProvider<TrelloStats?>((ref) async {
  ref.watch(trelloRefreshTickProvider);
  final repo = ref.watch(trelloRepositoryProvider);
  return repo.fetchBoardStats();
});
