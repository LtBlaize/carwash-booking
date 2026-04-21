import '../entities/location_entity.dart';
import '../entities/carwash_location_entity.dart';

abstract class MapRepository {
  Future<LocationEntity?> getCurrentLocation(); // ← nullable

  // unified: no lat/lng = fetch ALL
  Future<List<CarwashLocationEntity>> getCarwashes({
    double? latitude,
    double? longitude,
    double radiusKm = 10,
  });

  Future<List<CarwashLocationEntity>> filterSubscribedCarwashes({
    required List<CarwashLocationEntity> carwashes,
  });
}