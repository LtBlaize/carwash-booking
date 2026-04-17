import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/carwash_location_model.dart';

class CarwashGeoDatasource {
  final SupabaseClient supabase;

  CarwashGeoDatasource(this.supabase);

  Future<List<CarwashLocationModel>> getNearbyCarwashes({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    final res = await supabase.rpc(
      'nearby_carwashes',
      params: {
        'user_lat': latitude,
        'user_lng': longitude,
        'radius_km': radiusKm,
      },
    );

    return (res as List)
        .map((e) => CarwashLocationModel.fromMap(
              e,
              userLat: latitude,  // ✅ pass for haversine fallback
              userLng: longitude,
            ))
        .toList();
  }
}