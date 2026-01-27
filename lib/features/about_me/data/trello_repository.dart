import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../models/trello_stats.dart';

class TrelloRepository {
  TrelloRepository({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.trello.com/1'));

  final Dio _dio;

  Future<TrelloStats> fetchBoardStats() async {
    final key = AppConfig.trelloKey;
    final token = AppConfig.trelloToken;
    final boardId = AppConfig.trelloBoardId;

    final boardRes = await _dio.get(
      '/boards/$boardId',
      queryParameters: {
        'key': key,
        'token': token,
        'fields': 'name,desc,dateLastActivity,shortUrl',
      },
    );
    final board = boardRes.data as Map<String, dynamic>;
    final boardName = (board['name'] as String?) ?? 'Trello board';
    final boardUrl = (board['shortUrl'] as String?) ?? '';
    final last = board['dateLastActivity'] as String?;
    final lastAt = last == null ? null : DateTime.tryParse(last);

    final listsRes = await _dio.get(
      '/boards/$boardId/lists',
      queryParameters: {
        'key': key,
        'token': token,
        'fields': 'name,closed',
      },
    );
    final lists = (listsRes.data as List).cast<Map<String, dynamic>>();
    final activeLists = lists.where((l) => (l['closed'] as bool?) != true).toList();

    final cardsRes = await _dio.get(
      '/boards/$boardId/cards',
      queryParameters: {
        'key': key,
        'token': token,
        'fields': 'idList,closed,dateLastActivity',
      },
    );
    final cards = (cardsRes.data as List).cast<Map<String, dynamic>>();

    final listStats = <TrelloListStat>[];
    int totalCards = 0;
    int openCards = 0;

    for (final l in activeLists) {
      final listId = l['id'] as String?;
      if (listId == null) continue;
      final name = (l['name'] as String?) ?? 'List';

      final inList = cards.where((c) => c['idList'] == listId).toList();
      final total = inList.length;
      final open = inList.where((c) => (c['closed'] as bool?) != true).length;

      totalCards += total;
      openCards += open;

      listStats.add(
        TrelloListStat(name: name, totalCards: total, openCards: open),
      );
    }

    listStats.sort((a, b) => b.totalCards.compareTo(a.totalCards));

    return TrelloStats(
      boardName: boardName,
      boardUrl: boardUrl,
      lastActivityAt: lastAt,
      totalCards: totalCards,
      openCards: openCards,
      doneCards: totalCards - openCards,
      lists: listStats,
    );
  }
}
