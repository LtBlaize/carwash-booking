import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/carwash_location_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/location_datasource.dart';
import '../datasources/carwash_geo_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final LocationDatasource locationDatasource;
  final CarwashGeoDatasource carwashGeoDatasource;

  MapRepositoryImpl({
    required this.locationDatasource,
    required this.carwashGeoDatasource,
  });

  @override
  Future<LocationEntity> getCurrentLocation() =>
      locationDatasource.getCurrentLocation();

  @override
  Future<List<CarwashLocationEntity>> getNearbyCarwashes({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) =>
      carwashGeoDatasource.getNearbyCarwashes(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );

  @override
  Future<List<CarwashLocationEntity>> filterSubscribedCarwashes({
    required List<CarwashLocationEntity> carwashes,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    // Fetch subscribed carwash IDs for this user
    final res = await Supabase.instance.client
        .from('subscriptions')
        .select('carwash_id')
        .eq('user_id', user.id);

    final subscribedIds = Set<String>.from(
      List<Map<String, dynamic>>.from(res)
          .map((e) => e['carwash_id'].toString()),
    );

    return carwashes.where((c) => subscribedIds.contains(c.id)).toList();
  }
}