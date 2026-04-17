import '../entities/carwash_location_entity.dart';
import '../repositories/map_repository.dart';

class GetNearbyCarwashes {
  final MapRepository repository;
  const GetNearbyCarwashes(this.repository);

  Future<List<CarwashLocationEntity>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) =>
      repository.getNearbyCarwashes(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
}