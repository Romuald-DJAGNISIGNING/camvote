import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/tools_repository.dart';
import '../models/tools_models.dart';

final toolsRepositoryProvider = Provider<ToolsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiToolsRepository(dio);
});

final adminFraudInsightProvider = FutureProvider<FraudInsight>((ref) {
  return ref.read(toolsRepositoryProvider).fetchFraudInsight();
});

final adminDeviceRisksProvider = FutureProvider<List<DeviceRisk>>((ref) {
  return ref.read(toolsRepositoryProvider).fetchDeviceRisks();
});

final adminIncidentFilterProvider =
    NotifierProvider<AdminIncidentFilterController, String>(
  AdminIncidentFilterController.new,
);

class AdminIncidentFilterController extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String value) => state = value;
}

final adminIncidentsProvider =
    FutureProvider.family<List<IncidentOverview>, String>((ref, status) {
  return ref
      .read(toolsRepositoryProvider)
      .fetchIncidentOverview(status: status == 'all' ? null : status);
});

final adminResultsPublishingProvider =
    FutureProvider<List<ResultsPublishStatus>>((ref) {
  return ref.read(toolsRepositoryProvider).fetchResultsPublishing();
});

final observerIncidentFilterProvider =
    NotifierProvider<ObserverIncidentFilterController, String>(
  ObserverIncidentFilterController.new,
);

class ObserverIncidentFilterController extends Notifier<String> {
  @override
  String build() => 'all';

  void setFilter(String value) => state = value;
}

final observerIncidentsProvider =
    FutureProvider.family<List<IncidentOverview>, String>((ref, status) {
  return ref
      .read(toolsRepositoryProvider)
      .fetchObserverIncidents(status: status == 'all' ? null : status);
});

final observerTransparencyProvider =
    FutureProvider<List<TransparencyUpdate>>((ref) {
  return ref.read(toolsRepositoryProvider).fetchTransparencyFeed();
});

final observerChecklistProvider =
    FutureProvider<List<ObservationChecklistItem>>((ref) {
  return ref.read(toolsRepositoryProvider).fetchObservationChecklist();
});

final publicElectionCalendarProvider =
    FutureProvider<List<ElectionCalendarEntry>>((ref) {
  return ref.read(toolsRepositoryProvider).fetchElectionCalendar();
});

final publicCivicEducationProvider =
    FutureProvider<List<CivicLesson>>((ref) {
  return ref.read(toolsRepositoryProvider).fetchCivicLessons();
});
