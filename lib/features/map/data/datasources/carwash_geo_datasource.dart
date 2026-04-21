import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/carwash_location_model.dart';

class CarwashGeoDatasource {
  final SupabaseClient supabase;

  CarwashGeoDatasource(this.supabase);

  Future<List<CarwashLocationModel>> getCarwashes({
    double? latitude,
    double? longitude,
    double radiusKm = 10,
  }) async {
    // ✅ If no location → return ALL carwashes
    if (latitude == null || longitude == null) {
      final res = await supabase
          .from('carwashes')
          .select();

      return (res as List)
          .map((e) => CarwashLocationModel.fromMap(e))
          .toList();
    }

    // ✅ If location exists → use nearby RPC
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
              userLat: latitude,
              userLng: longitude,
            ))
        .toList();
  }
}