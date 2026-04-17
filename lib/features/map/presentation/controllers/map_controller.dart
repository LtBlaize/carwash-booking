import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/carwash_location_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_nearby_carwashes.dart';
import '../../domain/usecases/filter_subscribed_carwashes.dart';

class MapController extends ChangeNotifier {
  final GetCurrentLocation getCurrentLocation;
  final GetNearbyCarwashes getNearbyCarwashes;
  final FilterSubscribedCarwashes filterSubscribedCarwashes;

  MapController({
    required this.getCurrentLocation,
    required this.getNearbyCarwashes,
    required this.filterSubscribedCarwashes,
  });

  // Set from MapPage: (latLng, zoom) → _mapController.move(...)
  void Function(LatLng, double)? moveMap;

  LocationEntity? userLocation;
  List<CarwashLocationEntity> nearbyCarwashes = [];
  List<CarwashLocationEntity> filteredCarwashes = [];
  CarwashLocationEntity? selectedCarwash;

  bool isLoading = false;
  bool showSubscribedOnly = false;
  String searchQuery = '';
  String? error;

  List<CarwashLocationEntity> get displayList {
    final list = showSubscribedOnly ? filteredCarwashes : nearbyCarwashes;
    if (searchQuery.isEmpty) return list;
    return list
        .where(
            (c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      userLocation = await getCurrentLocation();
      nearbyCarwashes = await getNearbyCarwashes(
        latitude: userLocation!.latitude,
        longitude: userLocation!.longitude,
      );
      filteredCarwashes = await filterSubscribedCarwashes(
        carwashes: nearbyCarwashes,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCarwash(CarwashLocationEntity carwash) {
    selectedCarwash = carwash;
    // flutter_map uses move() — called from MapPage via the passed-in controller
    moveMap?.call(LatLng(carwash.latitude, carwash.longitude), 16);
    notifyListeners();
  }

  void clearSelection() {
    selectedCarwash = null;
    notifyListeners();
  }

  void toggleSubscribedFilter() {
    showSubscribedOnly = !showSubscribedOnly;
    notifyListeners();
  }

  void onSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void recenterToUser() {
    if (userLocation == null) return;
    moveMap?.call(LatLng(userLocation!.latitude, userLocation!.longitude), 14);
  }

  @override
  void dispose() {
    super.dispose();
  }
}