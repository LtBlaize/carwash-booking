import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';


import '../auth/auth_service.dart';
import '../auth/carwash_service.dart';

Map<String, dynamic>? carwash;

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    carwash = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  }
  final auth = AuthService();
  final carwashService = CarwashService();

  List<Map<String, dynamic>> carwashes = [];
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchCarwashes();
    fetchUpcomingBookings();
  }

  Future<void> _loadUserName() async {
    final name = await auth.getUserName();
    print('DEBUG name: $name');
    if (mounted) setState(() => userName = name);
  }

  Future<void> fetchCarwashes() async {
    final data = await carwashService.getCarwashes();
    if (mounted) {
      setState(() {
        carwashes = data;
        isLoading = false;
      });
    }
  }

  Future<void> fetchUpcomingBookings() async {
    final data = await carwashService.getUpcomingBookings();
    print('DEBUG bookings: $data');
    if (mounted) setState(() => bookings = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: SplashAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.muted, size: 20),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              'Hi $userName! 👋',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 2, 20, 12),
            child: Text(
              'Where are we washing today?',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ),

      
          
          // Section: Carwash Near Me
          const SectionTitle('Carwash Near Me'),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (carwashes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No car washes available.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          else
            ...carwashes.map((cw) {
              return _CarwashCard(
                name: cw['name'] ?? 'Car Wash',
                lastVisit: 'Available now',
                badgeLabel: 'Open',
                badgeBg: Colors.green.shade50,
                badgeColor: Colors.green,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/book',
                    arguments: cw,
                  );
                },
              );
            }).toList(),

          // Find car wash button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: OutlineButton2(
              '+ Find a Car Wash',
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}



// ─── Carwash Card ─────────────────────────────────────────────────────────────

class _CarwashCard extends StatelessWidget {
  final String name;
  final String lastVisit;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeColor;
  final VoidCallback onTap;

  const _CarwashCard({
    required this.name,
    required this.lastVisit,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ entire card is tappable
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.splashLight,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text('🏢', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastVisit,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.splash,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}