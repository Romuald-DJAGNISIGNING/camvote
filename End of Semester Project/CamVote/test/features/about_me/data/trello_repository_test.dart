import 'package:camvote/core/network/worker_client.dart';
import 'package:camvote/features/about_me/data/trello_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeWorkerClient extends WorkerClient {
  _FakeWorkerClient({this.response, this.error});

  final Map<String, dynamic>? response;
  final Object? error;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authRequired = true,
  }) async {
    if (error != null) throw error!;
    return response ?? const <String, dynamic>{};
  }
}

void main() {
  test('returns null when trello stats are not configured', () async {
    final repo = TrelloRepository(
      workerClient: _FakeWorkerClient(
        response: const {'ok': true, 'configured': false, 'stats': null},
      ),
    );

    expect(await repo.fetchBoardStats(), isNull);
  });

  test('rethrows worker failures instead of masking them as null', () async {
    final repo = TrelloRepository(
      workerClient: _FakeWorkerClient(
        error: WorkerException(
          'Unable to reach Trello board.',
          statusCode: 502,
        ),
      ),
    );

    await expectLater(
      repo.fetchBoardStats(),
      throwsA(
        isA<WorkerException>().having(
          (error) => error.message,
          'message',
          'Unable to reach Trello board.',
        ),
      ),
    );
  });

  test('parses explicit completion percent and task counters', () async {
    final repo = TrelloRepository(
      workerClient: _FakeWorkerClient(
        response: const {
          'ok': true,
          'configured': true,
          'stats': {
            'boardName': 'CamVote Roadmap',
            'boardUrl': 'https://trello.com/b/camvote',
            'lastActivityAt': '2026-03-07T10:45:00.000Z',
            'totalCards': 11,
            'remainingTasks': 3,
            'completedTasks': 8,
            'completionPercent': 73,
            'lists': [
              {'name': 'Done', 'totalCards': 8, 'openCards': 0},
            ],
          },
        },
      ),
    );

    final stats = await repo.fetchBoardStats();

    expect(stats, isNotNull);
    expect(stats!.boardName, 'CamVote Roadmap');
    expect(stats.completedTasks, 8);
    expect(stats.remainingTasks, 3);
    expect(stats.resolvedCompletionPercent, 73);
    expect(stats.lists, hasLength(1));
    expect(stats.lists.single.completionPercent, 100);
  });
}
