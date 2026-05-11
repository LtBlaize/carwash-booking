import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/booking/presentation/pages/book_page.dart';
import 'features/booking/presentation/pages/history_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

final client = Supabase.instance.client;
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Supabase.initialize(
    url: 'https://syemfjqtcvxfvmwcmkdg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5ZW1manF0Y3Z4ZnZtd2Nta2RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwMjgzNjIsImV4cCI6MjA5MTYwNDM2Mn0.bq-4guIG132carRocQTcqbaz3z0lL6oDXXsa_1F3KDs',
  );

  runApp(const MyApp());
}

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

// ─── MAIN SHELL (bottom nav wrapper) ─────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(),
    BookPage(),
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
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': '🏠', 'label': 'Home'},
      {'icon': '📅', 'label': 'Book'},
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
                          // ✅ FIX: withOpacity is deprecated in Flutter 3.27+.
                          //         Use Color.fromRGBO or withValues instead.
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
                          color: active
                              ? AppColors.splash
                              : AppColors.muted,
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