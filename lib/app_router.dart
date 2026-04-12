import 'package:go_router/go_router.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => HomePage(),
    ),
  ],
);