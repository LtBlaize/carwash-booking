import 'package:flutter/material.dart';

class AppColors {
  static const splash = Color(0xFF0EA5E9);
  static const splashDark = Color(0xFF0284C7);
  static const splashLight = Color(0xFFE0F2FE);
  static const splash50 = Color(0xFFF0F9FF);
  static const aqua = Color(0xFF14B8A6);
  static const aquaLight = Color(0xFFCCFBF1);
  static const navy = Color(0xFF082F49);
  static const navyMid = Color(0xFF0C4A6E);
  static const dark = Color(0xFF0F172A);
  static const body = Color(0xFF334155);
  static const muted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const card = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF8FAFC);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const emerald = Color(0xFF10B981);
  static const emeraldLight = Color(0xFFD1FAE5);
  static const rose = Color(0xFFF43F5E);
  static const purple = Color(0xFF8B5CF6);
  static const gold = Color(0xFFD97706);
  static const scaffoldDark = Color(0xFF1E293B);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C4A6E), Color(0xFF0EA5E9)],
  );

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C4A6E), Color(0xFF0EA5E9)],
  );

  static const purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  );
}

class AppTextStyles {
  static const String fontHeading = 'PlusJakartaSans';
  static const String fontBody = 'DMSans';

  static TextStyle heading1 = const TextStyle(
    fontFamily: fontHeading,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.dark,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: fontHeading,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static TextStyle heading3 = const TextStyle(
    fontFamily: fontHeading,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static TextStyle sectionTitle = const TextStyle(
    fontFamily: fontHeading,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static TextStyle body = const TextStyle(
    fontFamily: fontBody,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.body,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontBody,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static TextStyle label = const TextStyle(
    fontFamily: fontHeading,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
    letterSpacing: 0.5,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: AppTextStyles.fontBody,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.dark),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.splash,
          secondary: AppColors.aqua,
        ),
      );
}