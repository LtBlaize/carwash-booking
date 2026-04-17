import '../entities/location_entity.dart';
import '../entities/carwash_location_entity.dart';

abstract class MapRepository {
  Future<LocationEntity> getCurrentLocation();
  Future<List<CarwashLocationEntity>> getNearbyCarwashes({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  });
  Future<List<CarwashLocationEntity>> filterSubscribedCarwashes({
    required List<CarwashLocationEntity> carwashes,
  });
}