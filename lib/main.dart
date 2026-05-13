// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/booking/presentation/pages/history_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

final supabase = Supabase.instance.client;

// ✅ Global key so SplashAppBar can call resetToHome() without a push
final mainShellKey = GlobalKey<_MainShellState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await dotenv.load(fileName: 'assets/.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

// ─── MAIN SHELL ───────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // ✅ Called by SplashAppBar when already inside the shell
  void resetToHome() => setState(() => _currentIndex = 0);

  void _onTabTap(int i) {
    if (i == 1) {
      Navigator.pushNamed(context, '/map');
      return;
    }
    setState(() => _currentIndex = i);
  }

  final _pages = const [
    HomePage(),
    SizedBox.shrink(), // placeholder — tab 1 pushes /map
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': '🏠', 'label': 'Home'},
      {'icon': '🗺️', 'label': 'Map'},
      {'icon': '📋', 'label': 'History'},
      {'icon': '👤', 'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        items[i]['icon']!,
                        style: TextStyle(
                          fontSize: 20,
                          color: active
                              ? null
                              : Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label']!,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontHeading,
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color:
                              active ? AppColors.splash : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}