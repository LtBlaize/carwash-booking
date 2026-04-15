import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/shared_widgets.dart';

// ─── Data model ──────────────────────────────────────────────────────────────
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
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? user;
  List<Map<String, dynamic>> vehicles = [];
  List<VehicleBrand> vehicleBrands = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final currentUser = supabase.auth.currentUser;

    final userData = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();

    final vehicleData = await supabase
        .from('vehicles')
        .select()
        .eq('user_id', currentUser.id);

    // Fetch brands + models from your vehiclemodels SQL table
    // Expected schema: vehiclemodels(brand TEXT, model TEXT)
    final brandData = await supabase
        .from('vehiclemodels')
        .select('brand, model')
        .order('brand');

    // Group models by brand
    final Map<String, List<String>> brandMap = {};
    for (final row in brandData as List<dynamic>) {
      final brand = row['brand'] as String;
      final model = row['model'] as String;
      brandMap.putIfAbsent(brand, () => []).add(model);
    }

    setState(() {
      user = userData;
      vehicles = List<Map<String, dynamic>>.from(vehicleData);
      vehicleBrands = brandMap.entries
          .map((e) => VehicleBrand(brand: e.key, models: e.value))
          .toList();
      loading = false;
    });
  }

  Future<void> addVehicle(Map<String, dynamic> vehicleData) async {
  final currentUser = supabase.auth.currentUser;

  // 🔥 GET SIZE FROM vehiclemodels TABLE
  final modelData = await supabase
      .from('vehiclemodels')
      .select('size_id')
      .eq('brand', vehicleData['brand'])
      .eq('model', vehicleData['model'])
      .single();

  final sizeId = modelData['size_id'];

  // 🔥 INSERT WITH SIZE
  await supabase.from('vehicles').insert({
    ...vehicleData,
    'size_id': sizeId, // ✅ AUTO FILLED
    'user_id': currentUser!.id,
  });

  loadProfile();
}

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const SplashAppBar(),
      body: ListView(
        children: [
          // ── Profile header ─────────────────────────────────────────────
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
                Text(
                  user?['full_name'] ?? 'Loading...',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user?['phone']} · ${user?['email']}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── My Vehicles ────────────────────────────────────────────────
          const SectionTitle('My Vehicles'),

          ...vehicles.map((v) => _VehicleCard(
                emoji: '🚗',
                name: '${v['brand']} ${v['model']}',
                info: '${v['color']}',
                plate: v['plate_number'],
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
                    onAdd: addVehicle,
                    vehicleBrands: vehicleBrands,
                  ),
                );
              },
            ),
          ),

          // ── Settings ───────────────────────────────────────────────────
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
  List<String> _availableModels = [];

  final _colorController = TextEditingController();
  final _plateController = TextEditingController();

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
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
        fillColor:
            enabled ? const Color(0xFFF5F7FA) : const Color(0xFFEDF0F5),
      ),
      style: const TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
      hint: Text(
        enabled ? 'Select $label' : 'Select brand first',
        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ────────────────────────────────────────────────────
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
                      color: Colors.white.withOpacity(0.2),
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
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────────────────────
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

                      // Model (filtered by brand)
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

            // ── Actions ───────────────────────────────────────────────────
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
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text('Cancel',
                          style:
                              TextStyle(fontWeight: FontWeight.w600)),
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
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.muted),
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

// ─── Menu Item ────────────────────────────────────────────────────────────────
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
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            const Icon(Icons.chevron_right,
                color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}