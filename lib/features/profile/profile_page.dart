import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const SplashAppBar(),
      body: ListView(
        children: [
          // Profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.splash, AppColors.aqua],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'MS',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Maria Santos',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '0917-123-4567 · maria.santos@gmail.com',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // My Vehicles section
          const SectionTitle('My Vehicles'),

          _VehicleCard(
            emoji: '🚗',
            name: 'Toyota Vios 2020',
            info: 'Sedan · Medium · White',
            plate: 'ABC-1234',
          ),
          _VehicleCard(
            emoji: '🚙',
            name: 'Mitsubishi Xpander 2023',
            info: 'SUV · Large · Black',
            plate: 'DEF-5678',
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: OutlineButton2(
              '+ Add Vehicle',
              fullWidth: true,
              fontSize: 12,
            ),
          ),

          // Settings section
          const SectionTitle('Settings'),

          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                _MenuItem(
                  emoji: '👤',
                  iconBg: AppColors.splashLight,
                  title: 'Edit Profile',
                  subtitle: 'Name, email, phone number',
                ),
                _MenuItem(
                  emoji: '🔔',
                  iconBg: AppColors.amberLight,
                  title: 'Notifications',
                  subtitle: 'Push, SMS preferences',
                ),
                _MenuItem(
                  emoji: '🎁',
                  iconBg: const Color(0xFFF3E8FF),
                  title: 'Refer a Friend',
                  subtitle: 'Earn 100 pts per referral',
                ),
                _MenuItem(
                  emoji: '🔒',
                  iconBg: AppColors.emeraldLight,
                  title: 'Privacy & Security',
                  subtitle: 'Data, sessions',
                ),
                _MenuItem(
                  emoji: '🚪',
                  iconBg: const Color(0xFFFEE2E2),
                  title: 'Sign Out',
                  subtitle: '0917-123-4567',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String info;
  final String plate;

  const _VehicleCard({
    required this.emoji,
    required this.name,
    required this.info,
    required this.plate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  info,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.splash50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              plate,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isLast;

  const _MenuItem({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}