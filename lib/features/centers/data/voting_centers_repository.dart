import 'package:dio/dio.dart';

import '../models/voting_center.dart';

class VotingCentersRepository {
  VotingCentersRepository(this._dio);

  final Dio _dio;

  Future<List<VotingCenter>> fetchAll() async {
    final res = await _dio.get('/public/centers');
    return _parseCenters(res.data);
  }

  Future<List<VotingCenter>> fetchNearby({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    final res = await _dio.get(
      '/public/centers/nearby',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
    );
    return _parseCenters(res.data);
  }

  List<VotingCenter> _parseCenters(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(VotingCenter.fromJson)
        .toList();
  }
}
