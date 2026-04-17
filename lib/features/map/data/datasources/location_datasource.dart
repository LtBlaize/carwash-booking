import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_entity.dart';

abstract class LocationDatasource {
  Future<LocationEntity> getCurrentLocation();
}

class LocationDatasourceImpl implements LocationDatasource {
  @override
  Future<LocationEntity> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LocationEntity(latitude: pos.latitude, longitude: pos.longitude);
  }
}