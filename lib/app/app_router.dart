import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/booking/booking.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/map/presentation/controllers/map_controller.dart';
import '../features/map/domain/usecases/get_current_location.dart';    // ✅ domain, not data/domain
import '../features/map/domain/usecases/get_nearby_carwashes.dart';    // ✅ domain, not data/domain
import '../features/map/domain/usecases/filter_subscribed_carwashes.dart'; // ✅ domain, not data/domain
import '../features/map/data/repositories/map_repository_impl.dart';   // ✅ new
import '../features/map/data/datasources/location_datasource.dart';    // ✅ new
import '../features/map/data/datasources/carwash_geo_datasource.dart'; // ✅ new
import '../main.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
       case '/home':                                                      // ✅ re-added
        return MaterialPageRoute(builder: (_) => const MainShell());

      case '/map':
      final supabase = Supabase.instance.client;  // ✅ get the client once

      final locationDatasource = LocationDatasourceImpl();
      final carwashGeoDatasource = CarwashGeoDatasource(supabase); // ✅ pass it in
      final mapRepository = MapRepositoryImpl(
        locationDatasource: locationDatasource,
        carwashGeoDatasource: carwashGeoDatasource,
      );

      return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MapController(
            getCurrentLocation: GetCurrentLocation(mapRepository),
            getNearbyCarwashes: GetNearbyCarwashes(mapRepository),
            filterSubscribedCarwashes: FilterSubscribedCarwashes(mapRepository),
          ),
          child: const MapPage(),
        ),
      );
      case '/book':
        return MaterialPageRoute(
          builder: (_) => const BookPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}