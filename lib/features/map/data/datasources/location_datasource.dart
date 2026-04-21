import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_entity.dart';

abstract class LocationDatasource {
  Future<LocationEntity?> getCurrentLocation(); // ← nullable
}

class LocationDatasourceImpl implements LocationDatasource {
  @override
  Future<LocationEntity?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null; // ← null, not Manila

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LocationEntity(latitude: pos.latitude, longitude: pos.longitude);
    } catch (_) {
      return null;
    }
  }
}