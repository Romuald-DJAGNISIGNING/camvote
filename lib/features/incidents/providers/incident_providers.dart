import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../data/incident_repository.dart';
import '../models/incident_report.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiIncidentRepository(dio);
});

final incidentSubmissionProvider =
    AsyncNotifierProvider<IncidentSubmissionController, IncidentReportResult?>(
  IncidentSubmissionController.new,
);

class IncidentSubmissionController
    extends AsyncNotifier<IncidentReportResult?> {
  @override
  Future<IncidentReportResult?> build() async => null;

  Future<IncidentReportResult?> submit(IncidentReport report) async {
    if (!AppConfig.hasApiBaseUrl) {
      state = AsyncData(
        const IncidentReportResult(
          reportId: '',
          status: 'error',
          message: 'API base URL is not configured.',
        ),
      );
      return state.value;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(incidentRepositoryProvider);
      return repo.submitIncident(report);
    });

    return state.value;
  }
}
