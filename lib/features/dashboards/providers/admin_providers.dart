import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/admin_repository.dart';
import '../models/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiAdminRepository(dio);
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final repo = ref.read(adminRepositoryProvider);
  return repo.fetchAdminStats();
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
    AsyncNotifierProvider<ElectionsController, List<Election>>(ElectionsController.new);

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
