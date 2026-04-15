import 'package:flutter/material.dart';

import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/book/booking.dart';
import 'main.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/home':
        return MaterialPageRoute(builder: (_) => const MainShell());
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