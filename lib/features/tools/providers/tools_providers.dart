import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_settings_controller.dart';
import '../data/tools_repository.dart';
import '../models/tools_models.dart';

final toolsRepositoryProvider = Provider<ToolsRepository>((ref) {
  return ApiToolsRepository();
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

final observerTransparencyProvider = FutureProvider<List<TransparencyUpdate>>((
  ref,
) {
  final settings = ref.watch(appSettingsProvider).asData?.value;
  final locale = settings?.locale.languageCode ?? 'en';
  return ref
      .read(toolsRepositoryProvider)
      .fetchTransparencyFeed(localeCode: locale);
});

final observerChecklistProvider =
    FutureProvider<List<ObservationChecklistItem>>((ref) {
      final settings = ref.watch(appSettingsProvider).asData?.value;
      final locale = settings?.locale.languageCode ?? 'en';
      return ref
          .read(toolsRepositoryProvider)
          .fetchObservationChecklist(localeCode: locale);
    });

final publicElectionCalendarProvider =
    FutureProvider<List<ElectionCalendarEntry>>((ref) {
      final settings = ref.watch(appSettingsProvider).asData?.value;
      final locale = settings?.locale.languageCode ?? 'en';
      return ref
          .read(toolsRepositoryProvider)
          .fetchElectionCalendar(localeCode: locale);
    });

final publicCivicEducationProvider = FutureProvider<List<CivicLesson>>((ref) {
  final settings = ref.watch(appSettingsProvider).asData?.value;
  final locale = settings?.locale.languageCode ?? 'en';
  return ref
      .read(toolsRepositoryProvider)
      .fetchCivicLessons(localeCode: locale);
});
