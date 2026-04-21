import '../entities/location_entity.dart';
import '../repositories/map_repository.dart';

class GetCurrentLocation {
  final MapRepository repository;
  const GetCurrentLocation(this.repository);

  Future<LocationEntity?> call() => repository.getCurrentLocation(); // ← nullable
}