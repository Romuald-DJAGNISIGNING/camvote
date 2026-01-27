import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/network/api_client.dart';
import '../data/voting_centers_repository.dart';
import '../models/voting_center.dart';

final votingCentersRepositoryProvider = Provider<VotingCentersRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VotingCentersRepository(dio);
});

final votingCentersProvider =
    AsyncNotifierProvider<VotingCentersController, List<VotingCenter>>(
  VotingCentersController.new,
);

final votingCentersSearchProvider =
    NotifierProvider<VotingCentersSearchController, String>(
  VotingCentersSearchController.new,
);

class VotingCentersSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final votingCentersFilteredProvider = Provider<List<VotingCenter>>((ref) {
  final centers = ref.watch(votingCentersProvider).value ?? const [];
  final query = ref.watch(votingCentersSearchProvider).trim().toLowerCase();
  if (query.isEmpty) return centers;
  return centers
      .where(
        (c) =>
            c.name.toLowerCase().contains(query) ||
            c.address.toLowerCase().contains(query) ||
            c.regionCode.toLowerCase().contains(query),
      )
      .toList();
});

final votingCentersLocationProvider =
    NotifierProvider<VotingCentersLocationController, LatLng?>(
  VotingCentersLocationController.new,
);

class VotingCentersLocationController extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;

  void setLocation(LatLng? value) => state = value;
}

enum LocationFailureType {
  servicesDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class LocationFailure implements Exception {
  final LocationFailureType type;
  const LocationFailure(this.type);
}

class VotingCentersController extends AsyncNotifier<List<VotingCenter>> {
  VotingCentersRepository get _repo => ref.read(votingCentersRepositoryProvider);

  @override
  Future<List<VotingCenter>> build() async {
    return _repo.fetchAll();
  }

  Future<void> refreshAll() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchAll());
  }

  Future<void> loadNearby({double? radiusKm}) async {
    state = const AsyncLoading();
    final pos = await _resolvePosition();
    ref
        .read(votingCentersLocationProvider.notifier)
        .setLocation(LatLng(pos.latitude, pos.longitude));
    state = await AsyncValue.guard(
      () => _repo.fetchNearby(
        latitude: pos.latitude,
        longitude: pos.longitude,
        radiusKm: radiusKm,
      ),
    );
  }

  Future<Position> _resolvePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(LocationFailureType.servicesDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure(LocationFailureType.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationFailureType.permissionDeniedForever);
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
