import '../entities/carwash_location_entity.dart';
import '../repositories/map_repository.dart';

class GetCarwashes {
  final MapRepository repository;
  const GetCarwashes(this.repository);

  Future<List<CarwashLocationEntity>> call({
    double? latitude,
    double? longitude,
    double radiusKm = 10,
  }) =>
      repository.getCarwashes(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
}