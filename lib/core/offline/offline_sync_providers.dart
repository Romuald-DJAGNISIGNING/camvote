import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/worker_client.dart';
import 'offline_sync_service.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(workerClient: ref.watch(workerClientProvider));
});

final offlineSyncBootstrapProvider = Provider<void>((ref) {
  final service = ref.watch(offlineSyncServiceProvider);
  service.start();
  ref.onDispose(service.dispose);
});
