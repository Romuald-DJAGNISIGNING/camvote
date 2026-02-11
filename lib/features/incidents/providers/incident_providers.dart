import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/incident_repository.dart';
import '../models/incident_report.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return FirebaseIncidentRepository();
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(incidentRepositoryProvider);
      return repo.submitIncident(report);
    });

    return state.value;
  }
}
