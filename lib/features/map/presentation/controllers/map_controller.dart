import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/carwash_location_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_carwashes.dart';
import '../../domain/usecases/filter_subscribed_carwashes.dart';

class MapController extends ChangeNotifier {
  final GetCurrentLocation getCurrentLocation;
  final GetCarwashes getCarwashes;
  final FilterSubscribedCarwashes filterSubscribedCarwashes;

  MapController({
    required this.getCurrentLocation,
    required this.getCarwashes,
    required this.filterSubscribedCarwashes,
  });

  void Function(LatLng, double)? moveMap;

  LocationEntity? userLocation;
  bool locationDenied = false; // ← track denial explicitly

  List<CarwashLocationEntity> carwashList = [];
  List<CarwashLocationEntity> filteredCarwashes = [];
  CarwashLocationEntity? selectedCarwash;

  bool isLoading = false;
  bool showSubscribedOnly = false;
  String searchQuery = '';
  String? error;

  // Label for bottom sheet title
  String get listTitle =>
      locationDenied ? 'All Car Washes' : 'Nearby Car Washes';

  List<CarwashLocationEntity> get displayList {
    final list = showSubscribedOnly ? filteredCarwashes : carwashList;
    if (searchQuery.isEmpty) return list;
    return list
        .where((c) => c.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      userLocation = await getCurrentLocation(); // nullable
      locationDenied = userLocation == null;

      if (!locationDenied) {
        // ✅ Location allowed → fetch nearby, center map
        carwashList = await getCarwashes(
          latitude: userLocation!.latitude,
          longitude: userLocation!.longitude,
        );
        moveMap?.call(
          LatLng(userLocation!.latitude, userLocation!.longitude),
          14,
        );
      } else {
        // ✅ Location blocked → fetch ALL, stay on default center
        carwashList = await getCarwashes(); // no lat/lng = all
      }

      filteredCarwashes = await filterSubscribedCarwashes(
        carwashes: carwashList,
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
}