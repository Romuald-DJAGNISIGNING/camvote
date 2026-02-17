import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_tip_repository.dart';
import '../models/admin_tip_record.dart';

final adminTipRepositoryProvider = Provider<AdminTipRepository>((ref) {
  return AdminTipRepository();
});

final adminTipStatusFilterProvider =
    NotifierProvider<AdminTipStatusFilterNotifier, String>(
      AdminTipStatusFilterNotifier.new,
    );

class AdminTipStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'submitted';

  void setStatus(String value) {
    state = value;
  }
}

final adminTipsProvider = FutureProvider<List<AdminTipRecord>>((ref) async {
  final repo = ref.read(adminTipRepositoryProvider);
  final status = ref.watch(adminTipStatusFilterProvider);
  return repo.fetchTips(status: status);
});

final adminTipDecisionProvider = Provider<AdminTipDecisionController>((ref) {
  return AdminTipDecisionController(ref);
});

class AdminTipDecisionController {
  AdminTipDecisionController(this._ref);
  final Ref _ref;

  Future<AdminTipDecisionResult> decide({
    required String tipId,
    required String decision,
    String note = '',
  }) async {
    final repo = _ref.read(adminTipRepositoryProvider);
    final result = await repo.decideTip(
      tipId: tipId,
      decision: decision,
      note: note,
    );
    _ref.invalidate(adminTipsProvider);
    return result;
  }
}
