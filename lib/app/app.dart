// lib/app/app.dart

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carwash App',
      theme: AppTheme.theme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/login',
    );
  }
}