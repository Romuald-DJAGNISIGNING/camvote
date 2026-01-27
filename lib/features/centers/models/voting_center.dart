import 'package:flutter/foundation.dart';

@immutable
class VotingCenter {
  final String id;
  final String name;
  final String address;
  final String regionCode;
  final double latitude;
  final double longitude;
  final String status;
  final double? distanceKm;

  const VotingCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.regionCode,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.distanceKm,
  });

  factory VotingCenter.fromJson(Map<String, dynamic> json) {
    return VotingCenter(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      regionCode: (json['region_code'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as String?) ?? 'active',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'region_code': regionCode,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'distance_km': distanceKm,
      };

  bool get hasValidCoordinates => latitude != 0 && longitude != 0;
}
