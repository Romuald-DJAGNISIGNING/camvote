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
    final response = await _workerClient.get(
      '/v1/public/trello-stats',
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
      totalCards: _asInt(stats['totalCards'] ?? stats['totalTasks']),
      openCards: _asInt(
        stats['openCards'] ?? stats['openTasks'] ?? stats['remainingTasks'],
      ),
      doneCards: _asInt(stats['doneCards'] ?? stats['completedTasks']),
      completionPercent: _asOptionalInt(stats['completionPercent']),
      lists: lists,
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _asOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
