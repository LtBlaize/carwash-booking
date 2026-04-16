import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/carwash_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final data = await getUpcomingBookings();
    if (mounted) {
      setState(() {
        bookings = data;
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingBookings() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return [];

  final res = await Supabase.instance.client
      .from('bookings')
      .select('''
        booking_id,
        schedule,
        status,
        carwashes(name)
      ''')
      .eq('user_id', user.id)
      .gte('schedule', DateTime.now().toIso8601String())
      .order('schedule')
      .limit(1);

  return List<Map<String, dynamic>>.from(res);
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

          // Upcoming booking card
          _UpcomingCard(
            booking: bookings.isNotEmpty ? bookings.first : null,
            onTap: () {},
          ),

          // Promo banner
          _PromoBanner(),

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
            }),

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

// ─── Upcoming Card ────────────────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final Map<String, dynamic>? booking;
  final VoidCallback onTap;

  const _UpcomingCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border), // ✅ uniform — no crash
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Left accent bar as a separate widget — avoids non-uniform border crash
              Container(
                width: 4,
                color: AppColors.splash,
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: booking == null ? _noBooking() : _hasBooking(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noBooking() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📅 UPCOMING BOOKING',
          style: TextStyle(
            fontFamily: AppTextStyles.fontHeading,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.splash,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'No upcoming bookings',
          style: TextStyle(
            fontFamily: AppTextStyles.fontHeading,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Book a car wash below to get started!',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _hasBooking() {
    final carwashName =
        booking?['carwashes']?['name'] ?? 'Car Wash';

    final scheduleRaw = booking?['schedule'];
    final status = booking?['status'] ?? 'Pending';

    String formattedDate = 'No schedule';

    if (scheduleRaw != null) {
      final date = DateTime.tryParse(scheduleRaw.toString());

      if (date != null) {
        formattedDate =
            '${date.month}/${date.day}/${date.year} '
            '${date.hour > 12 ? date.hour - 12 : date.hour}:'
            '${date.minute.toString().padLeft(2, '0')} '
            '${date.hour >= 12 ? 'PM' : 'AM'}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 UPCOMING BOOKING',
          style: TextStyle(
            fontFamily: AppTextStyles.fontHeading,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.splash,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 8),

        // ROW 1: Name + View
        Row(
          children: [
            Expanded(
              child: Text(
                carwashName,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ),

            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.splash,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ROW 2: Date + Status + Reschedule
        Row(
          children: [
            Expanded(
              child: Text(
                '$formattedDate · $status',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                // TODO: reschedule logic
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.splashLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Reschedule',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.splashDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Promo Banner ─────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: 0.3,
                child: const Text('🚗', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎉 Double Points Weekend!',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Earn 2× points on all services this Saturday & Sunday',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
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