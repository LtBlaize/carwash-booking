// lib/features/booking/presentation/pages/book_page.dart
//
// Only _createBooking changed from the previous split version.
// The rest of the file (build, helpers, initState, etc.) is identical.
// Replace only this method in your book_page.dart.

// ─── REPLACE _createBooking with this ────────────────────────────────────────
//
// Future<void> _createBooking() async {
//   if (!_canBook || _isBooking) return;
//   setState(() => _isBooking = true);
//   HapticFeedback.mediumImpact();
//   try {
//     final selectedVehicle = _vehicles[_selectedVehicle!];
//     final slot = _slots[_selectedTimeSlot];
//     final schedule = _selectedDate.copyWith(
//       hour: _parseHour(slot['label'] as String),
//       minute: _parseMinute(slot['label'] as String),
//       second: 0,
//     );
//
//     final serviceIds = _selectedServices
//         .map((i) => _services[i]['service_id'].toString())
//         .toList();
//
//     final booking = await _controller.createBooking(
//       carwashId: _carwash!['carwash_id'].toString(),
//       vehicleId: selectedVehicle['vehicle_id'] as int,   // int, matches schema
//       vehicleSize: selectedVehicle['size_id'].toString(), // FK → sizes.size_id
//       schedule: schedule,
//       serviceIds: serviceIds,
//     );
//
//     if (booking == null) {
//       // controller already set _error; surface it
//       throw Exception(_controller.error ?? 'Booking failed');
//     }
//
//     if (context.mounted) {
//       await _showBookingSuccess();
//       Navigator.pop(context, true);
//     }
//   } catch (e) {
//     setState(() => _isBooking = false);
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Booking failed: ${e.toString()}'),
//           backgroundColor: Colors.red.shade700,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//   }
// }
//
// ─── ADD _controller field to _BookPageState ─────────────────────────────────
//
// late final BookingController _controller;
//
// ─── WIRE IT UP in initState (after addPostFrameCallback) ────────────────────
//
// _controller = BookingController(
//   createBookingUsecase: CreateBookingUsecase(
//     BookingRepositoryImpl(
//       BookingRemoteDatasourceImpl(Supabase.instance.client),
//     ),
//   ),
//   getBookingHistoryUsecase: GetBookingHistoryUsecase(
//     BookingRepositoryImpl(
//       BookingRemoteDatasourceImpl(Supabase.instance.client),
//     ),
//   ),
// );
//
// ─── ADD these imports to book_page.dart ─────────────────────────────────────
//
// import '../controllers/booking_controllers.dart';
// import '../../domain/usecases/create_booking_usecase.dart';
// import '../../domain/usecases/get_booking_usecase.dart';
// import '../../data/repositories/booking_repository_impl.dart';
// import '../../data/datasources/booking_remote_datasource.dart';

// -----------------------------------------------------------------------------
// Full updated book_page.dart with all changes applied:
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/theme/app_theme.dart';
import '/features/map/data/datasources/location_datasource.dart';
import '../controllers/booking_controllers.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_booking_usecase.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../widgets/booking_map_widget.dart';
import '../widgets/booking_cards.dart';
import '../widgets/booking_ui.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _carwash;

  int? _selectedVehicle;
  final Set<int> _selectedServices = {};
  int _selectedTimeSlot = -1;
  String? _selectedSize;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isBooking = false;

  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _services = [];
  bool _loadingVehicles = true;
  bool _loadingServices = false;

  double? _userLat;
  double? _userLng;

  late final BookingController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // TODO: replace with real availability query once the DB supports it
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

  double get _total {
    double sum = 0;
    for (final i in _selectedServices) {
      if (i < _services.length) {
        sum += (_services[i]['price'] as num?)?.toDouble() ?? 0;
      }
    }
    return sum;
  }

  bool get _canBook =>
      _vehicles.isNotEmpty &&
      _selectedVehicle != null &&
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

    // Wire up the controller locally. If you later use a DI solution
    // (e.g. Provider/GetIt), inject it from outside instead.
    _controller = BookingController(
      createBookingUsecase: CreateBookingUsecase(
        BookingRepositoryImpl(
          BookingRemoteDatasourceImpl(Supabase.instance.client),
        ),
      ),
      getBookingHistoryUsecase: GetBookingHistoryUsecase(
        BookingRepositoryImpl(
          BookingRemoteDatasourceImpl(Supabase.instance.client),
        ),
      ),
    );

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
      _carwash = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;
      if (mounted) setState(() {});
      _fetchVehicles();
      _loadUserLocation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
        _selectedVehicle = vehicles.isNotEmpty ? 0 : null;
      });
      if (vehicles.isNotEmpty) {
        _selectedSize = vehicles[0]['size_id']?.toString();
        await _fetchServices();
      }
    } catch (e) {
      debugPrint('VEHICLE ERROR: $e');
      if (!mounted) return;
      setState(() {
        _loadingVehicles = false;
        _loadingServices = false;
      });
    }
  }

  Future<void> _fetchServices() async {
    if (_carwash == null || _selectedSize == null) {
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
          .eq('carwash_id', _carwash!['carwash_id'].toString())
          .eq('size_id', _selectedSize!);
      final data = List<Map<String, dynamic>>.from(res);
      if (!mounted) return;
      setState(() {
        _services = data;
        _loadingServices = false;
        _selectedServices.clear();
      });
    } catch (e) {
      debugPrint('SERVICE ERROR: $e');
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
      final selectedVehicle = _vehicles[_selectedVehicle!];
      final slot = _slots[_selectedTimeSlot];
      final schedule = _selectedDate.copyWith(
        hour: _parseHour(slot['label'] as String),
        minute: _parseMinute(slot['label'] as String),
        second: 0,
      );

      // Collect service_id strings from the selected service rows.
      final serviceIds = _selectedServices
          .map((i) => _services[i]['service_id'].toString())
          .toList();

      final booking = await _controller.createBooking(
        carwashId: _carwash!['carwash_id'].toString(),
        vehicleId: selectedVehicle['vehicle_id'] as int,    // int — schema FK
        vehicleSize: selectedVehicle['size_id'].toString(), // FK → sizes.size_id
        schedule: schedule,
        serviceIds: serviceIds,
      );

      if (booking == null) {
        throw Exception(_controller.error ?? 'Booking failed');
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
                'Your appointment at ${_carwash?['name'] ?? 'the carwash'} has been booked.',
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
    final cwLat = (_carwash?['latitude'] as num?)?.toDouble();
    final cwLng = (_carwash?['longitude'] as num?)?.toDouble();

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
              _carwash?['name'] ?? 'Book Appointment',
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
          if (_carwash?['rating'] != null)
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
                    '${_carwash!['rating']}',
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
            BookingProgressBar(
              hasVehicle: _selectedVehicle != null,
              hasService: _selectedServices.isNotEmpty,
              hasTime: _selectedTimeSlot >= 0,
            ),
            const SizedBox(height: 8),

            if (cwLat != null && cwLng != null)
              BookingMap(
                carwashLat: cwLat,
                carwashLng: cwLng,
                carwashName: _carwash!['name'] ?? 'Car Wash',
                userLat: _userLat,
                userLng: _userLng,
                onDirectionsTap: () => _openDirections(cwLat, cwLng),
              ),

            const SizedBox(height: 4),

            // ── Step 1: Vehicle ───────────────────────────────────────────────
            BookingStep(
              stepNum: '1',
              title: 'Select Vehicle',
              isComplete: _selectedVehicle != null,
              child: _loadingVehicles
                  ? const BookingLoadingPlaceholder()
                  : _vehicles.isEmpty
                      ? BookingEmptyState(
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
                            return VehicleCard(
                              vehicle: v,
                              label: _vehicleLabel(v),
                              emoji: _vehicleEmoji(v),
                              info: _vehicleInfo(v),
                              isSelected: sel,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedVehicle = i;
                                  _selectedSize =
                                      _vehicles[i]['size_id']?.toString();
                                  _selectedServices.clear();
                                });
                                _fetchServices();
                              },
                            );
                          }),
                        ),
            ),

            // ── Step 2: Services ──────────────────────────────────────────────
            BookingStep(
              stepNum: '2',
              title: 'Select Services',
              isComplete: _selectedServices.isNotEmpty,
              child: _loadingServices && _services.isEmpty
                  ? const BookingLoadingPlaceholder()
                  : _services.isEmpty
                      ? const BookingEmptyState(
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
                                              _services.length,
                                              (i) => i));
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
                              final price =
                                  '₱${(s['price'] as num?)?.toStringAsFixed(0) ?? '0'}';
                              return ServiceCard(
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

            // ── Step 3: Date & Time ───────────────────────────────────────────
            BookingStep(
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
                  const Row(
                    children: [
                      SlotLegend(
                          color: AppColors.splash, label: 'Selected'),
                      SizedBox(width: 12),
                      SlotLegend(
                          color: AppColors.border, label: 'Available'),
                      SizedBox(width: 12),
                      SlotLegend(
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

            if (_services.isNotEmpty && _selectedServices.isNotEmpty)
              BookingSummary(
                selectedServices: _selectedServices,
                services: _services,
                total: _total,
                date: _formattedDate,
                timeSlot: _selectedTimeSlot >= 0
                    ? _slots[_selectedTimeSlot]['label'] as String
                    : null,
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                children: [
                  if (!_canBook) ...[
                    ValidationHints(
                      hasVehicle: _selectedVehicle != null,
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
                                      '₱${_total.toStringAsFixed(0)}',
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