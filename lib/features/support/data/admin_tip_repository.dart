import '../../../core/network/worker_client.dart';
import '../models/admin_tip_record.dart';

class AdminTipRepository {
  AdminTipRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Future<List<AdminTipRecord>> fetchTips({String status = ''}) async {
    final response = await _workerClient.get(
      '/v1/admin/tips',
      queryParameters: status.isEmpty ? null : {'status': status},
    );
    final raw = response['tips'];
    if (raw is! List) return const <AdminTipRecord>[];
    return raw
        .map(
          (e) => e is Map
              ? AdminTipRecord.fromApi(e.cast<String, dynamic>())
              : null,
        )
        .whereType<AdminTipRecord>()
        .toList();
  }

  Future<AdminTipDecisionResult> decideTip({
    required String tipId,
    required String decision,
    String note = '',
  }) async {
    final response = await _workerClient.post(
      '/v1/admin/tips/decide',
      data: {'tipId': tipId, 'decision': decision, 'note': note.trim()},
      allowOfflineQueue: true,
      queueType: 'tip_admin_decide',
    );
    return AdminTipDecisionResult(
      queuedOffline: response['queued'] == true,
      offlineQueueId: response['offlineQueueId']?.toString() ?? '',
    );
  }
}
