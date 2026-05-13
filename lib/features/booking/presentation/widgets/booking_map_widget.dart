// lib/features/booking/presentation/widgets/booking_map_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '/core/theme/app_theme.dart';

// ─── Booking Map ──────────────────────────────────────────────────────────────

class BookingMap extends StatelessWidget {
  final double carwashLat;
  final double carwashLng;
  final String carwashName;
  final double? userLat;
  final double? userLng;
  final VoidCallback onDirectionsTap;

  const BookingMap({
    super.key,
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
    final center = hasUserLocation
        ? LatLng(
            (userLat! + carwashLat) / 2,
            (userLng! + carwashLng) / 2,
          )
        : LatLng(carwashLat, carwashLng);
    final zoom = hasUserLocation ? 13.0 : 15.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on_rounded,
                  size: 15, color: AppColors.splash),
              SizedBox(width: 6),
              Text(
                'Location',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (hasUserLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: EtaBadge(
                userLat: userLat!,
                userLng: userLng!,
                carwashLat: carwashLat,
                carwashLng: carwashLng,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.location_off_rounded,
                      size: 13, color: Color(0xFF94A3B8)),
                  SizedBox(width: 5),
                  Text(
                    'Enable location to see ETA & directions',
                    style:
                        TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 180,
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
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                            color: AppColors.splash,
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
                              color: AppColors.splash,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.splash.withOpacity(0.4),
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
                                    color: AppColors.splash, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.splash,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: onDirectionsTap,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_rounded,
                      size: 15, color: AppColors.splash),
                  const SizedBox(width: 6),
                  Text(
                    hasUserLocation
                        ? 'Get Directions in Google Maps'
                        : 'View in Google Maps',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.splash,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ETA Badge ────────────────────────────────────────────────────────────────

class EtaBadge extends StatelessWidget {
  final double userLat, userLng, carwashLat, carwashLng;

  const EtaBadge({
    super.key,
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
        _badge(
          Icons.straighten_rounded,
          '${km.toStringAsFixed(1)} km away',
          const Color(0xFFEFF6FF),
          AppColors.splash,
        ),
        const SizedBox(width: 8),
        _badge(
          Icons.access_time_rounded,
          '~$mins min drive',
          const Color(0xFFF0FDF4),
          const Color(0xFF16A34A),
        ),
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