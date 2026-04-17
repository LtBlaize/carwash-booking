import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../../domain/entities/carwash_location_entity.dart';
import '../widgets/map_controls.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _searchController = TextEditingController();
  final _mapController = fm.MapController();

  // Default center: Naic, Cavite, Philippines
  static const _defaultCenter = LatLng(14.3167, 120.7667);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<MapController>();
      ctrl.moveMap = _mapController.move;
      ctrl.init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Consumer<MapController>(
          builder: (context, ctrl, _) {
            final center = ctrl.userLocation != null
                ? LatLng(
                    ctrl.userLocation!.latitude,
                    ctrl.userLocation!.longitude,
                  )
                : _defaultCenter;

            // Recenter map when user location updates
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ctrl.userLocation != null) {
                _mapController.move(center, 14);
              }
            });

            return Stack(
              children: [
                // ── Full-screen map ──────────────────────────────────────
                Positioned.fill(
                  child: fm.FlutterMap(
                    mapController: _mapController,
                    options: fm.MapOptions(
                      initialCenter: center,
                      initialZoom: 14,
                      onTap: (_, __) => ctrl.clearSelection(),
                    ),
                    children: [
                      // OpenStreetMap tile layer — free, no API key
                      fm.TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.carwash_booking',
                      ),

                      // User location marker
                      if (ctrl.userLocation != null)
                        fm.MarkerLayer(
                          markers: [
                            fm.Marker(
                              point: LatLng(
                                ctrl.userLocation!.latitude,
                                ctrl.userLocation!.longitude,
                              ),
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D4ED8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1D4ED8)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),

                      // Carwash markers
                      fm.MarkerLayer(
                        markers: ctrl.displayList.map((carwash) {
                          final isSelected =
                              ctrl.selectedCarwash?.id == carwash.id;
                          return fm.Marker(
                            point:
                                LatLng(carwash.latitude, carwash.longitude),
                            width: isSelected ? 48 : 36,
                            height: isSelected ? 48 : 36,
                            child: GestureDetector(
                              onTap: () => ctrl.selectCarwash(carwash),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1D4ED8)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1D4ED8),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.local_car_wash_rounded,
                                  size: isSelected ? 24 : 18,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ── Top overlay ──────────────────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Color(0x00FFFFFF),
                        ],
                        stops: [0, 0.7, 1],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _CircleIconButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Car Wash Near You',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: ctrl.onSearch,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF1E293B)),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Find a car wash by name...',
                                        hintStyle: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFADB5BD),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.search_rounded,
                                          size: 18,
                                          color: Color(0xFFADB5BD),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                MapFilterButton(
                                  isActive: ctrl.showSubscribedOnly,
                                  onTap: ctrl.toggleSubscribedFilter,
                                ),
                                const SizedBox(width: 8),
                                MapRecenterButton(
                                  onTap: () {
                                    if (ctrl.userLocation != null) {
                                      _mapController.move(
                                        LatLng(
                                          ctrl.userLocation!.latitude,
                                          ctrl.userLocation!.longitude,
                                        ),
                                        14,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Loading overlay ──────────────────────────────────────
                if (ctrl.isLoading)
                  Positioned(
                    top: 160,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Finding nearby car washes…',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Bottom sheet ─────────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomSheet(ctrl: ctrl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Bottom sheet ─────────────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final MapController ctrl;
  const _BottomSheet({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby Car Washes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (ctrl.displayList.isNotEmpty)
                      Text(
                        '${ctrl.displayList.length} found',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/home'),
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ctrl.displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🚿', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          ctrl.isLoading
                              ? 'Loading…'
                              : 'No car washes found nearby',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ctrl.displayList.length,
                    itemBuilder: (_, i) => _CarwashCard(
                      carwash: ctrl.displayList[i],
                      isSelected:
                          ctrl.selectedCarwash?.id == ctrl.displayList[i].id,
                      onTap: () => ctrl.selectCarwash(ctrl.displayList[i]),
                      onBook: () => Navigator.pushNamed(
                        context,
                        '/book',
                        arguments: {
                          'carwash_id': ctrl.displayList[i].id,
                          'name': ctrl.displayList[i].name,
                          'rating': ctrl.displayList[i].rating,
                        },
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D4ED8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Most Nearest',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Carwash card ─────────────────────────────────────────────────────────────
class _CarwashCard extends StatelessWidget {
  final CarwashLocationEntity carwash;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const _CarwashCard({
    required this.carwash,
    required this.isSelected,
    required this.onTap,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1D4ED8)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF1D4ED8).withOpacity(0.15)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: carwash.imageUrl != null
                  ? Image.network(
                      carwash.imageUrl!,
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PlaceholderImage(),
                    )
                  : _PlaceholderImage(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carwash.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 11, color: Color(0xFFFFB400)),
                        const SizedBox(width: 2),
                        Text(
                          '${carwash.rating.toStringAsFixed(1)} (${carwash.reviewCount})',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 10, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Text(
                          '${carwash.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.access_time_rounded,
                            size: 10, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Text(
                          '${carwash.estimatedMinutes} mins',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: const Text('🚿', style: TextStyle(fontSize: 28)),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: const Color(0xFF1E293B)),
      ),
    );
  }
}