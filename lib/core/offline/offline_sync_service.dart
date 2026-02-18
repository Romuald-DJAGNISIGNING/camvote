import 'dart:async';

import '../network/worker_client.dart';
import 'offline_sync_store.dart';

class OfflineSyncService {
  OfflineSyncService({required WorkerClient workerClient})
    : _workerClient = workerClient;

  final WorkerClient _workerClient;
  static const _maxRetryAttempts = 7;
  static const _maxRequestAge = Duration(days: 14);
  Timer? _timer;
  bool _started = false;
  bool _syncInFlight = false;

  void start() {
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      unawaited(flushPending());
    });
    unawaited(flushPending());
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  Future<int> flushPending({int maxItems = 8}) async {
    if (_syncInFlight) return 0;
    _syncInFlight = true;
    try {
      final queue = await OfflineSyncStore.loadQueuedRequests();
      if (queue.isEmpty) return 0;

      var flushedCount = 0;
      for (final request in queue.take(maxItems)) {
        final age = DateTime.now().toUtc().difference(
          request.createdAt.toUtc(),
        );
        if (request.attempts >= _maxRetryAttempts || age > _maxRequestAge) {
          await OfflineSyncStore.removeQueuedRequest(request.id);
          continue;
        }
        try {
          await _workerClient.post(
            request.path,
            data: request.data,
            authRequired: request.authRequired,
            allowOfflineQueue: false,
            queueType: request.queueType,
            replayingOfflineQueue: true,
          );
          await OfflineSyncStore.removeQueuedRequest(request.id);
          flushedCount += 1;
        } on WorkerException catch (error) {
          final status = error.statusCode ?? 0;
          final shouldDrop =
              status >= 400 &&
              status < 500 &&
              status != 401 &&
              status != 403 &&
              status != 429;
          if (shouldDrop) {
            await OfflineSyncStore.removeQueuedRequest(request.id);
            continue;
          }
          await OfflineSyncStore.markRetryFailure(
            request.id,
            error: error.message,
          );
          break;
        } catch (error) {
          await OfflineSyncStore.markRetryFailure(
            request.id,
            error: error.toString(),
          );
          break;
        }
      }
      return flushedCount;
    } finally {
      _syncInFlight = false;
    }
  }
}
