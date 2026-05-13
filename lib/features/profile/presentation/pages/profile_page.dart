// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class VehicleBrand {
  final String brand;
  final List<String> models;
  const VehicleBrand({required this.brand, required this.models});
}

// ─── Profile Page ─────────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _vehicles = [];
  List<VehicleBrand> _vehicleBrands = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ✅ FIX 6a: email from auth.currentUser, not profiles table
  // ✅ FIX 6b: try/catch so page doesn't crash on network error
  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _loading = false;
          _error = 'Not logged in.';
        });
        return;
      }

      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      final vehicleData = await _supabase
          .from('vehicles')
          .select()
          .eq('user_id', currentUser.id);

      final brandData = await _supabase
          .from('vehiclemodels')
          .select('brand, model')
          .order('brand');

      final Map<String, List<String>> brandMap = {};
      for (final row in brandData as List<dynamic>) {
        final brand = row['brand'] as String;
        final model = row['model'] as String;
        brandMap.putIfAbsent(brand, () => []).add(model);
      }

      if (!mounted) return;
      setState(() {
        _profile = {
          ...profileData,
          // ✅ FIX 6a: inject email from auth — profiles table has no email column
          'email': currentUser.email ?? '',
        };
        _vehicles = List<Map<String, dynamic>>.from(vehicleData);
        _vehicleBrands = brandMap.entries
            .map((e) => VehicleBrand(brand: e.key, models: e.value))
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load profile. Please try again.';
      });
    }
  }

  // ✅ FIX 6c: initials derived from actual full_name
  String _initials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _addVehicle(Map<String, dynamic> vehicleData) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      final modelData = await _supabase
          .from('vehiclemodels')
          .select('size_id')
          .eq('brand', vehicleData['brand'])
          .eq('model', vehicleData['model'])
          .single();

      await _supabase.from('vehicles').insert({
        ...vehicleData,
        'size_id': modelData['size_id'],
        'user_id': currentUser.id,
      });

      _loadProfile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add vehicle: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✅ FIX 7: Sign Out actually signs out and navigates to /login
  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ FIX 6b: show error state instead of crashing
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: const SplashAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 13)),
              const SizedBox(height: 12),
              OutlineButton2('Retry', onTap: _loadProfile),
            ],
          ),
        ),
      );
    }

    final fullName = _profile?['full_name']?.toString() ?? '';
    final email = _profile?['email']?.toString() ?? '';
    final phone = _profile?['phone']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const SplashAppBar(),
      body: ListView(
        children: [
          // ── Profile header ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
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
                  // ✅ FIX 6c: real initials from name
                  child: Text(
                    _initials(fullName),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  fullName.isNotEmpty ? fullName : 'No name set',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [phone, email]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── My Vehicles ─────────────────────────────────────────────────
          const SectionTitle('My Vehicles'),

          ..._vehicles.map((v) => _VehicleCard(
                emoji: _vehicleEmoji(v),
                name: '${v['brand']} ${v['model']}',
                info: [v['color'], v['type']]
                    .where((s) => s != null && s.toString().isNotEmpty)
                    .join(' · '),
                plate: v['plate_number'] ?? '',
              )),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: OutlineButton2(
              '+ Add Vehicle',
              fullWidth: true,
              fontSize: 12,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AddVehicleDialog(
                    onAdd: _addVehicle,
                    vehicleBrands: _vehicleBrands,
                  ),
                );
              },
            ),
          ),

          // ── Settings ────────────────────────────────────────────────────
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
                  subtitle: 'Name, phone number',
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
                // ✅ FIX 7: Sign Out now calls _signOut, subtitle is no longer
                //           a placeholder phone number
                _MenuItem(
                  emoji: '🚪',
                  iconBg: const Color(0xFFFEE2E2),
                  title: 'Sign Out',
                  subtitle: 'Signed in as $email',
                  isLast: true,
                  onTap: _signOut,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _vehicleEmoji(Map<String, dynamic> v) {
    final type = v['type']?.toString().toLowerCase() ?? '';
    if (type.contains('suv') || type.contains('mpv')) return '🚙';
    if (type.contains('truck')) return '🛻';
    if (type.contains('van')) return '🚐';
    if (type.contains('motor') || type.contains('bike')) return '🏍️';
    return '🚗';
  }
}

// ─── Add Vehicle Dialog ───────────────────────────────────────────────────────

class AddVehicleDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final List<VehicleBrand> vehicleBrands;

  const AddVehicleDialog({
    required this.onAdd,
    required this.vehicleBrands,
    super.key,
  });

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBrand;
  String? _selectedModel;
  // ✅ FIX 10: vehicle type field restored
  String? _selectedType;
  List<String> _availableModels = [];

  final _colorController = TextEditingController();
  final _plateController = TextEditingController();

  static const _vehicleTypes = ['Sedan', 'SUV', 'MPV', 'Hatchback', 'Van', 'Truck', 'Motorcycle'];

  @override
  void dispose() {
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _onBrandChanged(String? brand) {
    setState(() {
      _selectedBrand = brand;
      _selectedModel = null;
      _availableModels = brand == null
          ? []
          : widget.vehicleBrands
              .firstWhere((b) => b.brand == brand)
              .models;
    });
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      labelStyle:
          const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    bool enabled = true,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: _fieldDecoration(label, icon).copyWith(
        fillColor: enabled
            ? const Color(0xFFF5F7FA)
            : const Color(0xFFEDF0F5),
      ),
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.expand_more_rounded,
          color: Color(0xFF94A3B8)),
      hint: Text(
        enabled ? 'Select $label' : 'Select brand first',
        style:
            const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Vehicle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.15),
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VEHICLE INFO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Brand
                      _buildDropdown<String>(
                        label: 'Brand',
                        icon: Icons.branding_watermark_outlined,
                        value: _selectedBrand,
                        items: widget.vehicleBrands
                            .map((b) => b.brand)
                            .toList(),
                        onChanged: _onBrandChanged,
                        validator: (v) =>
                            v == null ? 'Please select a brand' : null,
                      ),
                      const SizedBox(height: 12),

                      // Model
                      _buildDropdown<String>(
                        label: 'Model',
                        icon: Icons.directions_car_outlined,
                        value: _selectedModel,
                        items: _availableModels,
                        onChanged: (v) =>
                            setState(() => _selectedModel = v),
                        enabled: _selectedBrand != null,
                        validator: (v) =>
                            v == null ? 'Please select a model' : null,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ✅ FIX 10: Vehicle type dropdown restored
                      // Was: const SizedBox(height: 12) — a placeholder with no field
                      // Now inserts 'type' into vehicles table which has a type column
                      _buildDropdown<String>(
                        label: 'Type',
                        icon: Icons.category_outlined,
                        value: _selectedType,
                        items: _vehicleTypes,
                        onChanged: (v) =>
                            setState(() => _selectedType = v),
                        validator: (v) =>
                            v == null ? 'Please select a type' : null,
                      ),
                      const SizedBox(height: 12),

                      // Color
                      TextFormField(
                        controller: _colorController,
                        decoration: _fieldDecoration(
                            'Color', Icons.palette_outlined),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1E293B)),
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Plate Number
                      TextFormField(
                        controller: _plateController,
                        decoration: _fieldDecoration(
                            'Plate Number', Icons.pin_outlined),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1E293B)),
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                            color: Color(0xFFE2E8F0)),
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onAdd({
                            'brand': _selectedBrand!,
                            'model': _selectedModel!,
                            // ✅ FIX 10: type now included in insert payload
                            'type': _selectedType!,
                            'color': _colorController.text,
                            'plate_number': _plateController.text,
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF1D4ED8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Add Vehicle',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600)),
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

// ─── Vehicle Card ─────────────────────────────────────────────────────────────

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
            color: Colors.black.withValues(alpha: 0.04),
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
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
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

// ─── Menu Item ────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final String emoji;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isLast;
  // ✅ FIX 7: onTap is now a real parameter, not hardcoded () {}
  final VoidCallback? onTap;

  const _MenuItem({
    required this.emoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
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
              child: Text(emoji,
                  style: const TextStyle(fontSize: 16)),
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
            const Icon(Icons.chevron_right,
                color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}