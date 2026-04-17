import '../entities/carwash_location_entity.dart';
import '../repositories/map_repository.dart';

class FilterSubscribedCarwashes {
  final MapRepository repository;
  const FilterSubscribedCarwashes(this.repository);

  Future<List<CarwashLocationEntity>> call({
    required List<CarwashLocationEntity> carwashes,
  }) =>
      repository.filterSubscribedCarwashes(carwashes: carwashes);
}