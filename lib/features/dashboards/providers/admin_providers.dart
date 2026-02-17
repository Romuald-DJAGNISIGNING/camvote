import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../data/admin_content_seed_service.dart';
import '../models/admin_models.dart';
import '../../../core/network/worker_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return ApiAdminRepository(workerClient: ref.read(workerClientProvider));
});

final adminContentSeedServiceProvider = Provider<AdminContentSeedService>((
  ref,
) {
  return AdminContentSeedService();
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.fetchAdminStats();
});

final voterDemographicsProvider = FutureProvider<VoterDemographics>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.fetchVoterDemographics();
});

class ElectionsController extends AsyncNotifier<List<Election>> {
  @override
  Future<List<Election>> build() async {
    final repo = ref.read(adminRepositoryProvider);
    return repo.fetchElections();
  }

  Future<void> createElection({
    required String title,
    required ElectionType type,
    required DateTime startAt,
    required DateTime endAt,
    DateTime? registrationDeadline,
    DateTime? campaignStartsAt,
    DateTime? campaignEndsAt,
    DateTime? resultsPublishAt,
    DateTime? runoffOpensAt,
    DateTime? runoffClosesAt,
    String description = '',
    String scope = '',
    String location = '',
    String timezone = '',
    String ballotType = '',
    String eligibility = '',
  }) async {
    final repo = ref.read(adminRepositoryProvider);
    state = const AsyncLoading();
    final _ = await repo.createElection(
      title: title,
      type: type,
      startAt: startAt,
      endAt: endAt,
      registrationDeadline: registrationDeadline,
      campaignStartsAt: campaignStartsAt,
      campaignEndsAt: campaignEndsAt,
      resultsPublishAt: resultsPublishAt,
      runoffOpensAt: runoffOpensAt,
      runoffClosesAt: runoffClosesAt,
      description: description,
      scope: scope,
      location: location,
      timezone: timezone,
      ballotType: ballotType,
      eligibility: eligibility,
    );
    state = AsyncData(await repo.fetchElections());
    ref.invalidate(adminStatsProvider);
  }

  Future<void> addCandidate({
    required String electionId,
    required Candidate candidate,
  }) async {
    final repo = ref.read(adminRepositoryProvider);
    final current = state.asData?.value ?? const <Election>[];
    state = AsyncData(current);

    await repo.addCandidate(electionId: electionId, candidate: candidate);
    state = AsyncData(await repo.fetchElections());
  }
}

final electionsProvider =
    AsyncNotifierProvider<ElectionsController, List<Election>>(
      ElectionsController.new,
    );

class VotersQuery {
  final String query;
  final CameroonRegion? region;
  final VoterStatus? status;

  const VotersQuery({this.query = '', this.region, this.status});

  VotersQuery copyWith({
    String? query,
    CameroonRegion? region,
    VoterStatus? status,
    bool clearRegion = false,
    bool clearStatus = false,
  }) {
    return VotersQuery(
      query: query ?? this.query,
      region: clearRegion ? null : (region ?? this.region),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

final votersQueryProvider =
    NotifierProvider<VotersQueryController, VotersQuery>(
      VotersQueryController.new,
    );

class VotersQueryController extends Notifier<VotersQuery> {
  @override
  VotersQuery build() => const VotersQuery();

  void update(VotersQuery query) => state = query;
}

final votersProvider = FutureProvider<List<VoterAdminRecord>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  final q = ref.watch(votersQueryProvider);
  return repo.fetchVoters(query: q.query, region: q.region, status: q.status);
});

class ObserversQuery {
  final String query;

  const ObserversQuery({this.query = ''});

  ObserversQuery copyWith({String? query}) {
    return ObserversQuery(query: query ?? this.query);
  }
}

final observersQueryProvider =
    NotifierProvider<ObserversQueryController, ObserversQuery>(
      ObserversQueryController.new,
    );

class ObserversQueryController extends Notifier<ObserversQuery> {
  @override
  ObserversQuery build() => const ObserversQuery();

  void update(ObserversQuery query) => state = query;
}

final observersProvider = FutureProvider<List<ObserverAdminRecord>>((
  ref,
) async {
  final repo = ref.read(adminRepositoryProvider);
  final q = ref.watch(observersQueryProvider);
  return repo.fetchObservers(query: q.query);
});

final observerRoleControllerProvider = Provider<ObserverRoleController>((ref) {
  return ObserverRoleController(ref);
});

class ObserverRoleController {
  final Ref _ref;
  ObserverRoleController(this._ref);

  Future<ObserverAdminRecord> setRole({
    required String identifier,
    required bool grant,
  }) async {
    final repo = _ref.read(adminRepositoryProvider);
    final record = await repo.setObserverRole(
      identifier: identifier,
      grant: grant,
    );
    _ref.invalidate(observersProvider);
    _ref.invalidate(adminStatsProvider);
    _ref.invalidate(auditEventsProvider);
    return record;
  }

  Future<ObserverAdminRecord> createObserver({
    required String fullName,
    required String email,
    required String temporaryPassword,
    String username = '',
  }) async {
    final repo = _ref.read(adminRepositoryProvider);
    final record = await repo.createObserver(
      fullName: fullName,
      email: email,
      temporaryPassword: temporaryPassword,
      username: username,
    );
    _ref.invalidate(observersProvider);
    _ref.invalidate(adminStatsProvider);
    _ref.invalidate(auditEventsProvider);
    return record;
  }

  Future<void> deleteObserver({required String identifier}) async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.deleteObserver(identifier: identifier);
    _ref.invalidate(observersProvider);
    _ref.invalidate(adminStatsProvider);
    _ref.invalidate(auditEventsProvider);
  }
}

final auditFilterProvider =
    NotifierProvider<AuditFilterController, AuditEventType?>(
      AuditFilterController.new,
    );

class AuditFilterController extends Notifier<AuditEventType?> {
  @override
  AuditEventType? build() => null;

  void setFilter(AuditEventType? value) => state = value;
}

final auditEventsProvider = FutureProvider<List<AuditEvent>>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  final type = ref.watch(auditFilterProvider);
  return repo.fetchAuditEvents(type: type);
});

final listCleaningControllerProvider = Provider<ListCleaningController>((ref) {
  return ListCleaningController(ref);
});

class ListCleaningController {
  final Ref _ref;
  ListCleaningController(this._ref);

  Future<void> runCleaning() async {
    final repo = _ref.read(adminRepositoryProvider);
    await repo.runElectoralListCleaning();
    _ref.invalidate(votersProvider);
    _ref.invalidate(adminStatsProvider);
    _ref.invalidate(auditEventsProvider);
  }
}
