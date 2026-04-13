import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              'Hi Maria! 👋',
              style: TextStyle(
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
          _UpcomingCard(),

          // Promo banner
          _PromoBanner(),

          // Section: My Car Washes
          const SectionTitle('My Car Washes'),

          // Car wash card 1
          _CarwashCard(
            name: 'AquaShine — Makati',
            lastVisit: 'Last visit: 3 days ago',
            badgeLabel: '🥇 Gold · 1,240 pts',
            badgeBg: AppColors.amberLight,
            badgeColor: AppColors.gold,
          ),

          // Car wash card 2
          _CarwashCard(
            name: 'SpeedyWash — Cebu',
            lastVisit: 'Last visit: 2 weeks ago',
            badgeLabel: '🥈 Silver · 620 pts',
            badgeBg: const Color(0xFFF1F5F9),
            badgeColor: const Color(0xFF64748B),
          ),

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

class _UpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.splash, width: 4),
          right: BorderSide(color: AppColors.border),
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
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
          const SizedBox(height: 6),
          const Text(
            'AquaShine — Makati',
            style: TextStyle(
              fontFamily: AppTextStyles.fontHeading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Saturday, Mar 29 at 9:00 AM · Basic Wash + Tire Shine',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.splash,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'View Queue',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.splashLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Reschedule',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.splashDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarwashCard extends StatelessWidget {
  final String name;
  final String lastVisit;
  final String badgeLabel;
  final Color badgeBg;
  final Color badgeColor;

  const _CarwashCard({
    required this.name,
    required this.lastVisit,
    required this.badgeLabel,
    required this.badgeBg,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.muted),
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
    );
  }
}