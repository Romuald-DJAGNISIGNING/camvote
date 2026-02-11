import 'package:flutter/foundation.dart';

@immutable
class VotingCenter {
  final String id;
  final String name;
  final String address;
  final String regionCode;
  final String regionName;
  final String city;
  final String country;
  final String countryCode;
  final String type;
  final double latitude;
  final double longitude;
  final String status;
  final String contact;
  final String notes;
  final double? distanceKm;

  const VotingCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.regionCode,
    required this.regionName,
    required this.city,
    required this.country,
    required this.countryCode,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.contact,
    required this.notes,
    required this.distanceKm,
  });

  factory VotingCenter.fromJson(Map<String, dynamic> json) {
    return VotingCenter(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      regionCode: (json['region_code'] as String?) ?? '',
      regionName: (json['region_name'] as String?) ?? '',
      city: (json['city'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      countryCode: (json['country_code'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'domestic',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      status: (json['status'] as String?) ?? 'active',
      contact: (json['contact'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'region_code': regionCode,
    'region_name': regionName,
    'city': city,
    'country': country,
    'country_code': countryCode,
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'contact': contact,
    'notes': notes,
    'distance_km': distanceKm,
  };

  bool get hasValidCoordinates => latitude != 0 && longitude != 0;

  bool get isAbroad =>
      countryCode.trim().isNotEmpty && countryCode.trim().toUpperCase() != 'CM';

  String get displayCountry =>
      country.isNotEmpty ? country : (isAbroad ? countryCode : '');

  String get displaySubtitle {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (regionName.isNotEmpty) parts.add(regionName);
    if (displayCountry.isNotEmpty) parts.add(displayCountry);
    if (parts.isNotEmpty) return parts.join(' • ');
    return address;
  }

  VotingCenter copyWith({
    String? id,
    String? name,
    String? address,
    String? regionCode,
    String? regionName,
    String? city,
    String? country,
    String? countryCode,
    String? type,
    double? latitude,
    double? longitude,
    String? status,
    String? contact,
    String? notes,
    double? distanceKm,
  }) {
    return VotingCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      regionCode: regionCode ?? this.regionCode,
      regionName: regionName ?? this.regionName,
      city: city ?? this.city,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      contact: contact ?? this.contact,
      notes: notes ?? this.notes,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
