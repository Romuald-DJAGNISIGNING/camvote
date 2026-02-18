import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tip_repository.dart';
import '../models/tip_models.dart';

final tipRepositoryProvider = Provider<TipRepository>((ref) {
  return TipRepository();
});

final pendingOfflineTipQueueProvider = StreamProvider<int>((ref) async* {
  final repo = ref.watch(tipRepositoryProvider);
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
  });
  yield await repo.pendingOfflineTipQueueCount();
  while (!disposed) {
    await Future<void>.delayed(const Duration(seconds: 6));
    if (disposed) break;
    yield await repo.pendingOfflineTipQueueCount();
  }
});

final tipCheckoutProvider =
    AsyncNotifierProvider<TipCheckoutController, TipCheckoutSession?>(
      TipCheckoutController.new,
    );

class TipCheckoutController extends AsyncNotifier<TipCheckoutSession?> {
  int _requestVersion = 0;

  @override
  Future<TipCheckoutSession?> build() async => null;

  void clear() {
    state = const AsyncData(null);
  }

  void setSession(TipCheckoutSession? session) {
    state = AsyncData(session);
  }

  Future<TipCheckoutSession?> createTapTapSend({
    required String senderName,
    required String senderEmail,
    required int amount,
    required String currency,
    bool anonymous = false,
    String message = '',
  }) async {
    return _runCheckoutRequest((repo) {
      return repo.createTapTapSendIntent(
        senderName: senderName,
        senderEmail: senderEmail,
        amount: amount,
        currency: currency,
        anonymous: anonymous,
        message: message,
        source: 'camvote_taptap_send',
      );
    });
  }

  Future<TipCheckoutSession?> createMaxItQr({
    required String senderName,
    required String senderEmail,
    required int amount,
    required String currency,
    bool anonymous = false,
    String message = '',
  }) async {
    return _runCheckoutRequest((repo) {
      return repo.createMaxItQrIntent(
        senderName: senderName,
        senderEmail: senderEmail,
        amount: amount,
        currency: currency,
        anonymous: anonymous,
        message: message,
        source: 'camvote_maxit_qr',
      );
    });
  }

  Future<TipCheckoutSession?> createRemitly({
    required String senderName,
    required String senderEmail,
    required int amount,
    required String currency,
    bool anonymous = false,
    String message = '',
  }) async {
    return _runCheckoutRequest((repo) {
      return repo.createRemitlyIntent(
        senderName: senderName,
        senderEmail: senderEmail,
        amount: amount,
        currency: currency,
        anonymous: anonymous,
        message: message,
        source: 'camvote_remitly',
      );
    });
  }

  Future<TipCheckoutSession?> _runCheckoutRequest(
    Future<TipCheckoutSession> Function(TipRepository repo) request,
  ) async {
    if (state.isLoading) return state.value;
    final version = ++_requestVersion;
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      final repo = ref.read(tipRepositoryProvider);
      return request(repo);
    });
    if (version != _requestVersion) {
      return state.value;
    }
    state = next;
    return state.value;
  }
}

final tipStatusProvider =
    AsyncNotifierProvider<TipStatusController, TipStatusResult?>(
      TipStatusController.new,
    );

class TipStatusController extends AsyncNotifier<TipStatusResult?> {
  static const Duration _minimumRefreshSpacing = Duration(seconds: 2);
  DateTime? _lastRefreshAt;
  String _lastTipId = '';

  @override
  Future<TipStatusResult?> build() async => null;

  void clear() {
    state = const AsyncData(null);
  }

  Future<TipStatusResult?> refresh(String tipId) async {
    final normalized = tipId.trim();
    if (normalized.isEmpty) return state.value;
    if (state.isLoading && normalized == _lastTipId) {
      return state.value;
    }
    final now = DateTime.now();
    final wasRecentlyRefreshed =
        normalized == _lastTipId &&
        _lastRefreshAt != null &&
        now.difference(_lastRefreshAt!) < _minimumRefreshSpacing;
    if (wasRecentlyRefreshed && state.hasValue) {
      return state.value;
    }
    _lastTipId = normalized;
    _lastRefreshAt = now;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(tipRepositoryProvider);
      return repo.fetchStatus(normalized);
    });
    return state.value;
  }

  Future<void> notifySuccess(String tipId) async {
    final normalized = tipId.trim();
    if (normalized.isEmpty) return;
    final repo = ref.read(tipRepositoryProvider);
    await repo.notifyTip(normalized, inApp: true, email: true);
  }
}
