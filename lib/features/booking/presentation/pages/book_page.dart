import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/carwash_service.dart';
import '../../../map/data/datasources/location_datasource.dart';

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
    carwash = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>?;

    // Load user location only when in detail mode
    if (carwash != null && !_locationLoaded) {
      _locationLoaded = true;
      _loadUserLocation();
    }
  }

  final auth = AuthService();
  final carwashService = CarwashService();
  final _locationDatasource = LocationDatasourceImpl();

  List<Map<String, dynamic>> carwashes = [];
  bool isLoading = true;
  String userName = '';

  // Map state
  bool _locationLoaded = false;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    fetchCarwashes();
  }

  Future<void> _loadUserName() async {
    final name = await auth.getUserName();
    if (mounted) setState(() => userName = name);
  }

  Future<void> fetchCarwashes() async {
    final data = await carwashService.getCarwashes();
    if (mounted) setState(() { carwashes = data; isLoading = false; });
  }

  Future<void> _loadUserLocation() async {
    final loc = await _locationDatasource.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLat = loc?.latitude;
        _userLng = loc?.longitude;
      });
    }
  }

  // Opens Google Maps with directions from user to carwash
  Future<void> _openDirections(double toLat, double toLng) async {
    final uri = _userLat != null && _userLng != null
        ? Uri.parse(
            'https://www.google.com/maps/dir/?api=1'
            '&origin=$_userLat,$_userLng'
            '&destination=$toLat,$toLng'
            '&travelmode=driving')
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1'
            '&query=$toLat,$toLng');

    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    // ── Detail mode ──────────────────────────────────────────────────────────
    if (carwash != null) {
      final lat = (carwash!['latitude'] as num?)?.toDouble();
      final lng = (carwash!['longitude'] as num?)?.toDouble();
      final name = carwash!['name'] as String? ?? 'Car Wash';

      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: AppColors.dark),
          title: Text(
            name,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontHeading,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
        ),
        body: ListView(
          children: [
            // ── Map section ───────────────────────────────────────────────
            if (lat != null && lng != null)
              _BookingMap(
                carwashLat: lat,
                carwashLng: lng,
                carwashName: name,
                userLat: _userLat,
                userLng: _userLng,
                onDirectionsTap: () => _openDirections(lat, lng),
              ),

            const SizedBox(height: 16),

            // ── Vehicle selector ──────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Select Your Vehicle',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ),
            _VehiclePlaceholder(),

            const SizedBox(height: 20),

            // ── Book button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: ElevatedButton(
                onPressed: () {/* booking logic */},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.splash,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── List mode ────────────────────────────────────────────────────────────
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
          const SectionTitle('All Carwashes'),
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
            ...carwashes.map((cw) => _CarwashCard(
                  name: cw['name'] ?? 'Car Wash',
                  lastVisit: 'Available now',
                  badgeLabel: 'Open',
                  badgeBg: Colors.green.shade50,
                  badgeColor: Colors.green,
                  onTap: () => Navigator.pushNamed(
                    context, '/book', arguments: cw,
                  ),
                )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: OutlineButton2('+ Find a Car Wash', fullWidth: true),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Map ──────────────────────────────────────────────────────────────

class _BookingMap extends StatelessWidget {
  final double carwashLat;
  final double carwashLng;
  final String carwashName;
  final double? userLat;
  final double? userLng;
  final VoidCallback onDirectionsTap;

  const _BookingMap({
    required this.carwashLat,
    required this.carwashLng,
    required this.carwashName,
    required this.userLat,
    required this.userLng,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUserLocation = userLat != null && userLng != null;

    // Center between user and carwash if both exist, else just carwash
    final center = hasUserLocation
        ? LatLng(
            (userLat! + carwashLat) / 2,
            (userLng! + carwashLng) / 2,
          )
        : LatLng(carwashLat, carwashLng);

    // Tighter zoom when only carwash, wider when showing route
    final zoom = hasUserLocation ? 13.0 : 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── ETA badge (only when user location is available) ────────────
        if (hasUserLocation)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _EtaBadge(
              userLat: userLat!,
              userLng: userLng!,
              carwashLat: carwashLat,
              carwashLng: carwashLng,
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.location_off_rounded,
                    size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 6),
                Text(
                  'Enable location to see ETA & directions',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),

        // ── Map ──────────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            child: IgnorePointer(
              child: fm.FlutterMap(
                options: fm.MapOptions(
                  initialCenter: center,
                  initialZoom: zoom,
                  interactionOptions: const fm.InteractionOptions(
                    flags: fm.InteractiveFlag.none,
                  ),
                ),
                children: [
                  fm.TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.carwash_booking',
                  ),
                  if (hasUserLocation)
                    fm.PolylineLayer(
                      polylines: [
                        fm.Polyline(
                          points: [
                            LatLng(userLat!, userLng!),
                            LatLng(carwashLat, carwashLng),
                          ],
                          strokeWidth: 3,
                          color: const Color(0xFF1D4ED8),
                          
                        ),
                      ],
                    ),
                  fm.MarkerLayer(
                    markers: [
                      fm.Marker(
                        point: LatLng(carwashLat, carwashLng),
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D4ED8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1D4ED8).withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_car_wash_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      if (hasUserLocation)
                        fm.Marker(
                          point: LatLng(userLat!, userLng!),
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF1D4ED8), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF1D4ED8),
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ), // ← closes FlutterMap
            ),   // ← closes IgnorePointer
          ),     // ← closes Container
        ),       // ← closes ClipRRect

        // ── Directions button ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: GestureDetector(
            onTap: onDirectionsTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_rounded,
                      size: 16, color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 6),
                  Text(
                    hasUserLocation
                        ? 'Get Directions in Google Maps'
                        : 'View in Google Maps',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── ETA Badge ────────────────────────────────────────────────────────────────



// ─── ETA Badge ────────────────────────────────────────────────────────────────

class _EtaBadge extends StatelessWidget {
  final double userLat, userLng, carwashLat, carwashLng;

  const _EtaBadge({
    required this.userLat,
    required this.userLng,
    required this.carwashLat,
    required this.carwashLng,
  });

  double _distanceKm() {
    const r = 6371.0;
    final dLat = (carwashLat - userLat) * math.pi / 180;
    final dLng = (carwashLng - userLng) * math.pi / 180;
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(userLat * math.pi / 180) *
            math.cos(carwashLat * math.pi / 180) *
            math.pow(math.sin(dLng / 2), 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  @override
  Widget build(BuildContext context) {
    final km = _distanceKm();
    final mins = (km / 0.5).ceil().clamp(1, 120);

    return Row(
      children: [
        _badge(Icons.straighten_rounded, '${km.toStringAsFixed(1)} km away',
            const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
        const SizedBox(width: 8),
        _badge(Icons.access_time_rounded, '~$mins min drive',
            const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
      ],
    );
  }

  Widget _badge(IconData icon, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ─── Vehicle placeholder ──────────────────────────────────────────────────────

class _VehiclePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.directions_car_rounded,
              color: AppColors.muted, size: 20),
          SizedBox(width: 10),
          Text(
            'No vehicles added yet',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ─── Carwash Card (list mode) ─────────────────────────────────────────────────

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
      onTap: onTap,
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