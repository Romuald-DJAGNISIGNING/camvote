import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../data/trello_repository.dart';
import '../models/trello_stats.dart';

final trelloRepositoryProvider =
    Provider<TrelloRepository>((ref) => TrelloRepository());

final trelloStatsProvider = FutureProvider<TrelloStats?>((ref) async {
  if (!AppConfig.hasTrelloConfig) return null;
  final repo = ref.watch(trelloRepositoryProvider);
  return repo.fetchBoardStats();
});
