import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../../features/map/data/datasources/location_datasource.dart';

Map<String, dynamic>? carwash;

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with TickerProviderStateMixin {
  int _selectedVehicle = 0;
  final Set<int> _selectedServices = {};
  int _selectedTimeSlot = -1;
  dynamic selectedSize;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isBooking = false;

  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _services = [];
  bool _loadingVehicles = true;
  bool _loadingServices = false;

  // Map state
  double? _userLat;
  double? _userLng;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final _slots = [
    {'label': '8:00 AM', 'avail': true},
    {'label': '8:30 AM', 'avail': false},
    {'label': '9:00 AM', 'avail': true},
    {'label': '9:30 AM', 'avail': true},
    {'label': '10:00 AM', 'avail': true},
    {'label': '10:30 AM', 'avail': true},
    {'label': '11:00 AM', 'avail': false},
    {'label': '11:30 AM', 'avail': true},
    {'label': '1:00 PM', 'avail': true},
    {'label': '1:30 PM', 'avail': true},
    {'label': '2:00 PM', 'avail': true},
    {'label': '2:30 PM', 'avail': false},
    {'label': '3:00 PM', 'avail': true},
    {'label': '3:30 PM', 'avail': true},
    {'label': '4:00 PM', 'avail': true},
    {'label': '4:30 PM', 'avail': true},
  ];

  int get _total {
    int sum = 0;
    for (final i in _selectedServices) {
      if (i < _services.length) {
        sum += int.tryParse(
                _services[i]['price'].toString().replaceAll('₱', '')) ??
            0;
      }
    }
    return sum;
  }

  bool get _canBook =>
      _vehicles.isNotEmpty &&
      _selectedServices.isNotEmpty &&
      _selectedTimeSlot >= 0;

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final d = _selectedDate;
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      carwash = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;
      if (mounted) setState(() {});
      _fetchVehicles();
      _loadUserLocation(); // ← load location on open
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    final loc = await LocationDatasourceImpl().getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLat = loc?.latitude;
        _userLng = loc?.longitude;
      });
    }
  }

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

  Future<void> _fetchVehicles() async {
    try {
      setState(() => _loadingVehicles = true);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _loadingVehicles = false);
        return;
      }
      final res = await Supabase.instance.client
          .from('vehicles')
          .select()
          .eq('user_id', user.id);
      final vehicles = List<Map<String, dynamic>>.from(res);
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _loadingVehicles = false;
        _selectedVehicle = 0;
      });
      if (vehicles.isNotEmpty) {
        selectedSize = vehicles[0]['size_id'].toString();
        await _fetchServices();
      }
    } catch (e) {
      print('VEHICLE ERROR: $e');
      if (!mounted) return;
      setState(() {
        _loadingVehicles = false;
        _loadingServices = false;
      });
    }
  }

  Future<void> _fetchServices() async {
    if (carwash == null || selectedSize == null) {
      setState(() => _loadingServices = false);
      return;
    }
    try {
      setState(() => _loadingServices = true);
      final res = await Supabase.instance.client
          .from('serviceprices')
          .select('''
            price,
            service_id,
            services (
              name,
              duration_minutes,
              description
            )
          ''')
          .eq('carwash_id', carwash!['carwash_id'].toString())
          .eq('size_id', selectedSize.toString());
      final data = List<Map<String, dynamic>>.from(res);
      if (!mounted) return;
      setState(() {
        _services = data;
        _loadingServices = false;
        _selectedServices.clear();
      });
    } catch (e) {
      print('SERVICE ERROR: $e');
      if (!mounted) return;
      setState(() {
        _services = [];
        _loadingServices = false;
      });
    }
  }

  Future<void> _createBooking() async {
    if (!_canBook || _isBooking) return;
    setState(() => _isBooking = true);
    HapticFeedback.mediumImpact();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final slot = _slots[_selectedTimeSlot];
      final schedule = _selectedDate.copyWith(
        hour: _parseHour(slot['label'] as String),
        minute: _parseMinute(slot['label'] as String),
        second: 0,
      );
      final bookingRes = await Supabase.instance.client
          .from('bookings')
          .insert({
            'user_id': user!.id,
            'carwash_id': carwash!['carwash_id'],
            'vehicle_id': _vehicles[_selectedVehicle]['vehicle_id'],
            'schedule': schedule.toIso8601String(),
            'status': 'Pending',
          })
          .select()
          .single();
      final bookingId = bookingRes['booking_id'];
      for (final i in _selectedServices) {
        await Supabase.instance.client.from('bookingservices').insert({
          'booking_id': bookingId,
          'service_id': _services[i]['service_id'],
        });
      }
      if (context.mounted) {
        await _showBookingSuccess();
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isBooking = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  int _parseHour(String label) {
    final parts =
        label.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    int h = int.parse(parts[0]);
    if (label.contains('PM') && h != 12) h += 12;
    if (label.contains('AM') && h == 12) h = 0;
    return h;
  }

  int _parseMinute(String label) {
    final parts =
        label.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    return int.parse(parts[1]);
  }

  Future<void> _showBookingSuccess() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.emerald, size: 44),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment at ${carwash?['name'] ?? 'the carwash'} has been booked.',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.splash,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.splash,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = -1;
      });
    }
  }

  String _vehicleEmoji(Map<String, dynamic> v) {
    final type = v['type']?.toString().toLowerCase() ?? '';
    if (type.contains('suv') || type.contains('mpv')) return '🚙';
    if (type.contains('truck')) return '🛻';
    if (type.contains('van')) return '🚐';
    if (type.contains('motor') || type.contains('bike')) return '🏍️';
    return '🚗';
  }

  String _vehicleLabel(Map<String, dynamic> v) {
    final brand = v['brand']?.toString() ?? '';
    final model = v['model']?.toString() ?? '';
    if (brand.isNotEmpty || model.isNotEmpty) return '$brand $model'.trim();
    return v['plate_number']?.toString() ?? 'Vehicle';
  }

  String _vehicleInfo(Map<String, dynamic> v) {
    return [v['plate_number'], v['type'], v['color']]
        .where((e) => e != null && e.toString().isNotEmpty)
        .join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final cwLat = (carwash?['latitude'] as num?)?.toDouble();
    final cwLng = (carwash?['longitude'] as num?)?.toDouble();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.dark),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              carwash?['name'] ?? 'Book Appointment',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const Text(
              'New Booking',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          if (carwash?['rating'] != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color(0xFFFFD700), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB400), size: 13),
                  const SizedBox(width: 3),
                  Text(
                    '${carwash!['rating']}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A5700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Progress bar
            _BookingProgressBar(
              hasVehicle: _vehicles.isNotEmpty,
              hasService: _selectedServices.isNotEmpty,
              hasTime: _selectedTimeSlot >= 0,
            ),
            const SizedBox(height: 8),

            // ── Map ──────────────────────────────────────────────────────
            if (cwLat != null && cwLng != null)
              _BookingMap(
                carwashLat: cwLat,
                carwashLng: cwLng,
                carwashName: carwash!['name'] ?? 'Car Wash',
                userLat: _userLat,
                userLng: _userLng,
                onDirectionsTap: () => _openDirections(cwLat, cwLng),
              ),

            const SizedBox(height: 4),

            // Step 1: Vehicle
            _BookingStep(
              stepNum: '1',
              title: 'Select Vehicle',
              isComplete: _vehicles.isNotEmpty,
              child: _loadingVehicles
                  ? const _LoadingPlaceholder()
                  : _vehicles.isEmpty
                      ? _EmptyState(
                          icon: Icons.directions_car_outlined,
                          message: 'No vehicles found.',
                          hint: 'Add a vehicle from your profile first.',
                          actionLabel: 'Add Vehicle',
                          onAction: () =>
                              Navigator.pushNamed(context, '/add-vehicle'),
                        )
                      : Column(
                          children: List.generate(_vehicles.length, (i) {
                            final v = _vehicles[i];
                            final sel = _selectedVehicle == i;
                            return _VehicleCard(
                              vehicle: v,
                              label: _vehicleLabel(v),
                              emoji: _vehicleEmoji(v),
                              info: _vehicleInfo(v),
                              isSelected: sel,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedVehicle = i;
                                  selectedSize = _vehicles[i]['size_id'];
                                  _selectedServices.clear();
                                });
                                _fetchServices();
                              },
                            );
                          }),
                        ),
            ),

            // Step 2: Services
            _BookingStep(
              stepNum: '2',
              title: 'Select Services',
              isComplete: _selectedServices.isNotEmpty,
              child: _loadingServices && _services.isEmpty
                  ? const _LoadingPlaceholder()
                  : _services.isEmpty
                      ? const _EmptyState(
                          icon: Icons.cleaning_services_outlined,
                          message: 'No services available.',
                          hint: 'No services found for this vehicle size.',
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() {
                                    if (_selectedServices.length ==
                                        _services.length) {
                                      _selectedServices.clear();
                                    } else {
                                      _selectedServices.addAll(
                                          List.generate(
                                              _services.length, (i) => i));
                                    }
                                  }),
                                  child: Text(
                                    _selectedServices.length ==
                                            _services.length
                                        ? 'Deselect All'
                                        : 'Select All',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.splash,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(_services.length, (i) {
                              final s = _services[i];
                              final sel = _selectedServices.contains(i);
                              final name =
                                  (s['services'] as Map?)?['name']
                                          ?.toString() ??
                                      'Service';
                              final desc =
                                  (s['services'] as Map?)?['description']
                                          ?.toString() ??
                                      '';
                              final durationMin = (s['services']
                                  as Map?)?['duration_minutes'];
                              final duration = durationMin != null
                                  ? '$durationMin min'
                                  : '';
                              final price = '₱${s['price']}';
                              return _ServiceCard(
                                name: name,
                                description: desc,
                                duration: duration,
                                price: price,
                                isSelected: sel,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    if (sel) {
                                      _selectedServices.remove(i);
                                    } else {
                                      _selectedServices.add(i);
                                    }
                                  });
                                },
                              );
                            }),
                          ],
                        ),
            ),

            // Step 3: Date & Time
            _BookingStep(
              stepNum: '3',
              title: 'Pick Date & Time',
              isComplete: _selectedTimeSlot >= 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: AppColors.splash, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: AppColors.splash, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formattedDate,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                          const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.splash,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      _SlotLegend(
                          color: AppColors.splash, label: 'Selected'),
                      SizedBox(width: 12),
                      _SlotLegend(
                          color: AppColors.border, label: 'Available'),
                      SizedBox(width: 12),
                      _SlotLegend(
                          color: Color(0xFFE5E7EB),
                          label: 'Unavailable',
                          strikethrough: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 7,
                      mainAxisSpacing: 7,
                      childAspectRatio: 2.3,
                    ),
                    itemCount: _slots.length,
                    itemBuilder: (_, i) {
                      final slot = _slots[i];
                      final avail = slot['avail'] as bool;
                      final sel = _selectedTimeSlot == i && avail;
                      return GestureDetector(
                        onTap: avail
                            ? () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedTimeSlot = i);
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.splash
                                : avail
                                    ? Colors.white
                                    : const Color(0xFFF3F4F6),
                            border: Border.all(
                              color: sel
                                  ? AppColors.splash
                                  : AppColors.border,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                      color: AppColors.splash
                                          .withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            slot['label'] as String,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontHeading,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : avail
                                      ? AppColors.body
                                      : AppColors.muted,
                              decoration: avail
                                  ? TextDecoration.none
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Booking summary
            if (_services.isNotEmpty && _selectedServices.isNotEmpty)
              _BookingSummary(
                selectedServices: _selectedServices,
                services: _services,
                total: _total,
                date: _formattedDate,
                timeSlot: _selectedTimeSlot >= 0
                    ? _slots[_selectedTimeSlot]['label'] as String
                    : null,
              ),

            // Book button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                children: [
                  if (!_canBook) ...[
                    _ValidationHints(
                      hasVehicle: _vehicles.isNotEmpty,
                      hasService: _selectedServices.isNotEmpty,
                      hasTime: _selectedTimeSlot >= 0,
                    ),
                    const SizedBox(height: 10),
                  ],
                  GestureDetector(
                    onTap: _canBook ? _createBooking : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _canBook
                            ? AppColors.splash
                            : AppColors.muted.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _canBook
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.splash.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: _isBooking
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('📅',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Book Appointment',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontHeading,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _canBook
                                        ? Colors.white
                                        : AppColors.muted,
                                  ),
                                ),
                                if (_canBook && _total > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '₱$_total',
                                      style: const TextStyle(
                                        fontFamily:
                                            AppTextStyles.fontHeading,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
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
          // Header
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

          // ETA badges
          if (hasUserLocation)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EtaBadge(
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

          // Map
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
                                  color:
                                      AppColors.splash.withOpacity(0.4),
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

          // Directions button
          GestureDetector(
            onTap: onDirectionsTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 14),
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
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
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

// ─── Sub-widgets (unchanged) ──────────────────────────────────────────────────

class _BookingProgressBar extends StatelessWidget {
  final bool hasVehicle;
  final bool hasService;
  final bool hasTime;

  const _BookingProgressBar({
    required this.hasVehicle,
    required this.hasService,
    required this.hasTime,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [hasVehicle, hasService, hasTime];
    final completed = steps.where((s) => s).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$completed of 3 steps completed',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              ...List.generate(3, (i) {
                final done = steps[i];
                return Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: done ? AppColors.emerald : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completed / 3,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.splash),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStep extends StatelessWidget {
  final String stepNum;
  final String title;
  final Widget child;
  final bool isComplete;

  const _BookingStep({
    required this.stepNum,
    required this.title,
    required this.child,
    this.isComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isComplete
              ? AppColors.emerald.withOpacity(0.4)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color:
                        isComplete ? AppColors.emerald : AppColors.splash,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isComplete
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 14)
                      : Text(
                          stepNum,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                if (isComplete) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.emerald, size: 14),
                ],
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final String label;
  final String emoji;
  final String info;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.label,
    required this.emoji,
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.splash50 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.splash : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.splash.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  if (info.isNotEmpty)
                    Text(
                      info,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted),
                    ),
                ],
              ),
            ),
            if (vehicle['size'] != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  vehicle['size'].toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.body,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.splash : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.splash : AppColors.border,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final String description;
  final String duration;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.emerald : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.emerald.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.emerald
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.emerald
                        : AppColors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(Icons.check,
                        color: Colors.white, size: 13)
                    : null,
              ),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        description,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (duration.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 11, color: AppColors.muted),
                          const SizedBox(width: 3),
                          Text(
                            duration,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              price,
              style: TextStyle(
                fontFamily: AppTextStyles.fontHeading,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.emerald : AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  final Set<int> selectedServices;
  final List<Map<String, dynamic>> services;
  final int total;
  final String date;
  final String? timeSlot;

  const _BookingSummary({
    required this.selectedServices,
    required this.services,
    required this.total,
    required this.date,
    this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    int totalMinutes = 0;
    for (final i in selectedServices) {
      final mins = (services[i]['services'] as Map?)?['duration_minutes'];
      totalMinutes += int.tryParse(mins?.toString() ?? '0') ?? 0;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.splash50,
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.receipt_long_rounded,
                  size: 15, color: AppColors.splash),
              SizedBox(width: 6),
              Text(
                'Booking Summary',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...selectedServices.map((i) {
            final name =
                (services[i]['services'] as Map?)?['name']?.toString() ??
                    'Service';
            final price = '₱${services[i]['price']}';
            return _SummaryRow(name, price);
          }),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFBAE6FD), height: 16),
          if (timeSlot != null) _SummaryRow('📅  $date at $timeSlot', ''),
          if (totalMinutes > 0)
            _SummaryRow('⏱️  Est. duration', '$totalMinutes min'),
          const Divider(color: Color(0xFFBAE6FD), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              Text(
                '₱$total',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.splash,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✨', style: TextStyle(fontSize: 12)),
                SizedBox(width: 5),
                Text(
                  '+32 points earned · Gold member discount applied',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.body)),
          ),
          if (value.isNotEmpty)
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.body)),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.splash,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, color: AppColors.border, size: 36),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark)),
          const SizedBox(height: 2),
          Text(hint,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.muted)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.splash,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidationHints extends StatelessWidget {
  final bool hasVehicle;
  final bool hasService;
  final bool hasTime;

  const _ValidationHints({
    required this.hasVehicle,
    required this.hasService,
    required this.hasTime,
  });

  @override
  Widget build(BuildContext context) {
    final hints = <String>[];
    if (!hasVehicle) hints.add('Select a vehicle');
    if (!hasService) hints.add('Choose at least one service');
    if (!hasTime) hints.add('Pick a time slot');
    if (hints.isEmpty) return const SizedBox.shrink();

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border:
            Border.all(color: const Color(0xFFFDBA74), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 15, color: Color(0xFFEA580C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'To continue: ${hints.join(', ')}.',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9A3412)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool strikethrough;

  const _SlotLegend({
    required this.color,
    required this.label,
    this.strikethrough = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.muted,
            decoration: strikethrough
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
      ],
    );
  }
}