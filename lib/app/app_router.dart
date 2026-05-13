// lib/app/app_router.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/booking/presentation/pages/book_page.dart';
import '../features/booking/presentation/pages/history_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/map/presentation/controllers/map_controller.dart';
import '../features/map/domain/usecases/get_current_location.dart';
import '../features/map/domain/usecases/get_carwashes.dart';
import '../features/map/domain/usecases/filter_subscribed_carwashes.dart';
import '../features/map/data/repositories/map_repository_impl.dart';
import '../features/map/data/datasources/location_datasource.dart';
import '../features/map/data/datasources/carwash_geo_datasource.dart';
import '../main.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/home':
  return MaterialPageRoute(builder: (_) => MainShell(key: mainShellKey),);
      case '/map':
        {
          final supabaseClient = Supabase.instance.client;
          final locationDatasource = LocationDatasourceImpl();
          final carwashGeoDatasource =
              CarwashGeoDatasource(supabaseClient);
          final mapRepository = MapRepositoryImpl(
            locationDatasource: locationDatasource,
            carwashGeoDatasource: carwashGeoDatasource,
          );

          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => MapController(
                getCurrentLocation:
                    GetCurrentLocation(mapRepository),
                getCarwashes: GetCarwashes(mapRepository),
                filterSubscribedCarwashes:
                    FilterSubscribedCarwashes(mapRepository),
              ),
              child: const MapPage(),
            ),
          );
        }

      case '/book':
        return MaterialPageRoute(
          builder: (_) => const BookPage(),
          settings: settings, // preserves route arguments for _carwash
        );

      // ✅ FIX 9: /history and /profile were missing — deep links and any
      //           Navigator.pushNamed to them hit the fallback. Now registered.
      case '/history':
        return MaterialPageRoute(builder: (_) => const HistoryPage());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}