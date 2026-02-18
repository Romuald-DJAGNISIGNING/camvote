import '../../../core/network/worker_client.dart';
import '../models/trello_stats.dart';

class TrelloRepository {
  TrelloRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();
  final WorkerClient _workerClient;

  Future<TrelloStats?> fetchBoardStats() async {
    return _fetchFromWorker();
  }

  Future<TrelloStats?> _fetchFromWorker() async {
    try {
      final minuteStamp = DateTime.now().millisecondsSinceEpoch ~/ 60000;
      final response = await _workerClient.get(
        '/v1/public/trello-stats',
        queryParameters: {'t': minuteStamp.toString()},
        authRequired: false,
      );
      final configured = response['configured'] == true;
      if (!configured) return null;
      final stats =
          (response['stats'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final listsRaw = stats['lists'];
      final lists = listsRaw is List
          ? listsRaw
                .whereType<Map>()
                .map(
                  (entry) => TrelloListStat(
                    name: '${entry['name'] ?? 'List'}',
                    totalCards: _asInt(entry['totalCards']),
                    openCards: _asInt(entry['openCards']),
                  ),
                )
                .toList()
          : const <TrelloListStat>[];
      final lastRaw = '${stats['lastActivityAt'] ?? ''}'.trim();
      return TrelloStats(
        boardName: '${stats['boardName'] ?? 'Trello board'}'.trim(),
        boardUrl: '${stats['boardUrl'] ?? ''}'.trim(),
        lastActivityAt: lastRaw.isEmpty ? null : DateTime.tryParse(lastRaw),
        totalCards: _asInt(stats['totalCards']),
        openCards: _asInt(stats['openCards']),
        doneCards: _asInt(stats['doneCards']),
        lists: lists,
      );
    } catch (_) {
      return null;
    }
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
