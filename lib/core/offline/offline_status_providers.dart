import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_sync_store.dart';

final connectivityStatusProvider =
    StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final statuses = ref.watch(connectivityStatusProvider).asData?.value;
  if (statuses == null) return false;
  if (statuses.isEmpty) return true;
  return statuses.contains(ConnectivityResult.none);
});

final pendingOfflineQueueTotalProvider = StreamProvider<int>((ref) async* {
  yield await OfflineSyncStore.pendingCount();
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 6));
    yield await OfflineSyncStore.pendingCount();
  }
});
