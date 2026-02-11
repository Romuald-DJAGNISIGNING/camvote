import 'package:latlong2/latlong.dart';

import '../../../core/network/worker_client.dart';
import '../models/voting_center.dart';

class VotingCentersRepository {
  VotingCentersRepository({WorkerClient? workerClient})
    : _workerClient = workerClient ?? WorkerClient();

  final WorkerClient _workerClient;

  Stream<List<VotingCenter>> watchAll() {
    return _pollCenters();
  }

  Future<List<VotingCenter>> fetchAll() async {
    final response = await _workerClient.get(
      '/v1/centers',
      authRequired: false,
    );
    final items = response['centers'];
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((doc) {
          final data =
              (doc['data'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return VotingCenter.fromJson({'id': doc['id'] ?? '', ...data});
        })
        .toList();
  }

  Future<List<VotingCenter>> fetchNearby({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    final centers = await fetchAll();
    return withDistance(
      centers: centers,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  List<VotingCenter> withDistance({
    required List<VotingCenter> centers,
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) {
    final distance = const Distance();
    final origin = LatLng(latitude, longitude);
    final filtered = centers
        .where((center) => center.hasValidCoordinates)
        .map((center) {
          final km = distance.as(
            LengthUnit.Kilometer,
            origin,
            LatLng(center.latitude, center.longitude),
          );
          return center.copyWith(distanceKm: km);
        })
        .where(
          (center) => radiusKm == null || (center.distanceKm ?? 0) <= radiusKm,
        )
        .toList();
    filtered.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    return filtered;
  }

  Future<VotingCenter> upsert(VotingCenter center) async {
    final response = await _workerClient.post(
      '/v1/admin/centers/upsert',
      data: _centerPayload(center),
    );
    final id = response['id']?.toString() ?? center.id;
    return center.copyWith(id: id);
  }

  Future<void> delete(String id) async {
    if (id.trim().isEmpty) return;
    await _workerClient.post(
      '/v1/admin/centers/delete',
      data: {'id': id.trim()},
    );
  }

  Future<void> upsertBatch(List<VotingCenter> centers) async {
    if (centers.isEmpty) return;
    await _workerClient.post(
      '/v1/admin/centers/batch',
      data: {'centers': centers.map(_centerPayload).toList()},
    );
  }

  Stream<List<VotingCenter>> _pollCenters() async* {
    yield await fetchAll();
    yield* Stream.periodic(
      const Duration(minutes: 5),
    ).asyncMap((_) => fetchAll());
  }

  Map<String, dynamic> _centerPayload(VotingCenter center) => {
    'id': center.id,
    'name': center.name.trim(),
    'address': center.address.trim(),
    'region_code': center.regionCode.trim(),
    'region_name': center.regionName.trim(),
    'city': center.city.trim(),
    'country': center.country.trim(),
    'country_code': center.countryCode.trim().toUpperCase(),
    'type': center.type.trim(),
    'latitude': center.latitude,
    'longitude': center.longitude,
    'status': center.status.trim(),
    'contact': center.contact.trim(),
    'notes': center.notes.trim(),
  };
}
