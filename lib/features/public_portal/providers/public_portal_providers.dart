import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/public_portal_repository.dart';
import '../models/public_models.dart';

final publicPortalRepositoryProvider = Provider<PublicPortalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PublicPortalRepository(dio);
});

final publicResultsProvider =
    FutureProvider.autoDispose<PublicResultsState>((ref) async {
  final repo = ref.watch(publicPortalRepositoryProvider);
  return repo.fetchResults();
});

/// Privacy-safe lookup attempt limiter (client-side only).
final lookupLimiterProvider =
    NotifierProvider<LookupLimiterController, LookupLimiterState>(LookupLimiterController.new);

class LookupLimiterState {
  final List<DateTime> attempts;

  const LookupLimiterState({required this.attempts});

  int get countLast10Min {
    final cut = DateTime.now().subtract(const Duration(minutes: 10));
    return attempts.where((a) => a.isAfter(cut)).length;
  }

  bool get blocked => countLast10Min >= 5;

  Duration get cooldown {
    if (!blocked) return Duration.zero;

    final cut = DateTime.now().subtract(const Duration(minutes: 10));
    final recent = attempts.where((a) => a.isAfter(cut)).toList()..sort();
    final firstInWindow = recent.first;
    final until = firstInWindow.add(const Duration(minutes: 10));
    final left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }
}

class LookupLimiterController extends Notifier<LookupLimiterState> {
  @override
  LookupLimiterState build() => const LookupLimiterState(attempts: []);

  void recordAttempt() {
    state = LookupLimiterState(attempts: [...state.attempts, DateTime.now()]);
  }

  void reset() {
    state = const LookupLimiterState(attempts: []);
  }
}
