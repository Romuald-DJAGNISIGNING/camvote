import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/voting_centers_repository.dart';
import '../models/voting_center.dart';

final votingCentersRepositoryProvider = Provider<VotingCentersRepository>((
  ref,
) {
  return VotingCentersRepository();
});

final votingCentersProvider =
    AsyncNotifierProvider<VotingCentersController, List<VotingCenter>>(
      VotingCentersController.new,
    );

final votingCentersSearchProvider =
    NotifierProvider<VotingCentersSearchController, String>(
      VotingCentersSearchController.new,
    );

enum VotingCentersFilter { all, cameroon, abroad, embassies }

final votingCentersFilterProvider =
    NotifierProvider<VotingCentersFilterController, VotingCentersFilter>(
      VotingCentersFilterController.new,
    );

class VotingCentersFilterController extends Notifier<VotingCentersFilter> {
  @override
  VotingCentersFilter build() => VotingCentersFilter.all;

  void setFilter(VotingCentersFilter value) => state = value;
}

class VotingCentersSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final votingCentersFilteredProvider = Provider<List<VotingCenter>>((ref) {
  final centers = ref.watch(votingCentersProvider).value ?? const [];
  final query = ref.watch(votingCentersSearchProvider).trim().toLowerCase();
  final filter = ref.watch(votingCentersFilterProvider);
  final filteredByScope = _applyFilter(centers, filter);
  if (query.isEmpty) return filteredByScope;
  return filteredByScope
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
  VotingCentersRepository get _repo =>
      ref.read(votingCentersRepositoryProvider);
  StreamSubscription<List<VotingCenter>>? _subscription;
  List<VotingCenter> _cached = const [];
  bool _nearbyMode = false;

  @override
  Future<List<VotingCenter>> build() async {
    _subscription?.cancel();
    _subscription = _repo.watchAll().listen((centers) {
      _cached = centers;
      _emit();
    });
    ref.onDispose(() => _subscription?.cancel());
    _cached = await _repo.fetchAll();
    return _cached;
  }

  Future<void> refreshAll() async {
    _nearbyMode = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchAll());
  }

  Future<void> loadNearby({double? radiusKm}) async {
    _nearbyMode = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final pos = await _resolvePosition();
      ref
          .read(votingCentersLocationProvider.notifier)
          .setLocation(LatLng(pos.latitude, pos.longitude));
      final list = _repo.withDistance(
        centers: _cached,
        latitude: pos.latitude,
        longitude: pos.longitude,
        radiusKm: radiusKm,
      );
      return list;
    });
  }

  void _emit() {
    if (_nearbyMode) {
      final location = ref.read(votingCentersLocationProvider);
      if (location != null) {
        state = AsyncValue.data(
          _repo.withDistance(
            centers: _cached,
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        );
        return;
      }
    }
    state = AsyncValue.data(_cached);
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
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}

List<VotingCenter> _applyFilter(
  List<VotingCenter> centers,
  VotingCentersFilter filter,
) {
  switch (filter) {
    case VotingCentersFilter.cameroon:
      return centers.where((c) {
        final code = c.countryCode.trim().toUpperCase();
        return code.isEmpty || code == 'CM';
      }).toList();
    case VotingCentersFilter.abroad:
      return centers.where((c) => c.isAbroad).toList();
    case VotingCentersFilter.embassies:
      return centers.where((c) {
        final type = c.type.toLowerCase();
        return type.contains('embassy') ||
            type.contains('consulate') ||
            type.contains('mission') ||
            type.contains('commission');
      }).toList();
    case VotingCentersFilter.all:
      return centers;
  }
}
