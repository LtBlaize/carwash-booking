import '../../domain/entities/carwash_location_entity.dart';
import 'dart:math';

class CarwashLocationModel extends CarwashLocationEntity {
  const CarwashLocationModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.rating,
    required super.reviewCount,
    required super.distanceKm,
    required super.estimatedMinutes,
    super.imageUrl,
    super.isSubscribed,
    super.isOpen,
  });

  factory CarwashLocationModel.fromMap(
    Map<String, dynamic> map, {
    double? userLat,
    double? userLng,
  }) {
    final lat = (map['latitude'] as num).toDouble();
    final lng = (map['longitude'] as num).toDouble();
    final dist = (userLat != null && userLng != null)
        ? _haversine(userLat, userLng, lat, lng)
        : (map['distance_km'] as num?)?.toDouble() ?? 0.0;

    return CarwashLocationModel(
      id: map['carwash_id'].toString(),
      name: map['name'] as String,
      latitude: lat,
      longitude: lng,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
      distanceKm: dist,
      estimatedMinutes: (dist / 0.5).ceil().clamp(1, 60),
      imageUrl: map['image_url'] as String?,
      isSubscribed: map['is_subscribed'] as bool? ?? false,
      isOpen: map['is_open'] as bool? ?? true,
    );
  }

  static double _haversine(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _deg2rad(double deg) => deg * pi / 180;
}