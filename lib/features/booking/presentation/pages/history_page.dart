// lib/features/booking/presentation/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _client = Supabase.instance.client;

  // 0 = All, rest are carwash name substrings populated after load
  int _selectedFilter = 0;
  List<String> _filters = ['All'];
  List<Map<String, dynamic>> _allHistory = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _loading = false;
          _error = 'Not logged in.';
        });
        return;
      }

      final res = await _client
          .from('bookings')
          .select('''
            booking_id,
            schedule,
            status,
            carwashes (name),
            vehicles (brand, model, plate_number, color, type),
            bookingservices (
              services (name)
            )
          ''')
          .eq('user_id', userId)
          .order('schedule', ascending: false);

      final rows = List<Map<String, dynamic>>.from(res);

      // Build filter list from unique carwash names
      final names = rows
          .map((r) => (r['carwashes'] as Map?)?['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _allHistory = rows;
        _filters = ['All', ...names];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load history. Please try again.';
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 0) return _allHistory;
    final label = _filters[_selectedFilter];
    return _allHistory
        .where((r) =>
            ((r['carwashes'] as Map?)?['name']?.toString() ?? '') == label)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const SplashAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Service History'),

          // Pill filters — dynamic from real data
          if (_filters.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (i) {
                  final active = i == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6, bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppColors.splash : Colors.white,
                        border: Border.all(
                          color:
                              active ? AppColors.splash : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontHeading,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.muted,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 12),
            OutlineButton2('Retry', onTap: _loadHistory),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          'No bookings yet.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filtered.length,
        itemBuilder: (_, i) => _HistoryCard(item: _filtered[i]),
      ),
    );
  }
}

// ─── Status badge helper ──────────────────────────────────────────────────────

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'confirmed':
      return Colors.blue;
    case 'cancelled':
      return Colors.red;
    default: // Pending
      return Colors.orange;
  }
}

Color _statusBg(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green.shade50;
    case 'confirmed':
      return Colors.blue.shade50;
    case 'cancelled':
      return Colors.red.shade50;
    default:
      return Colors.orange.shade50;
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _HistoryCard({required this.item});

  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _serviceNames(dynamic bookingservices) {
    if (bookingservices == null) return '—';
    final list = bookingservices as List<dynamic>;
    if (list.isEmpty) return '—';
    return list
        .map((bs) =>
            (bs['services'] as Map?)?['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .join(' + ');
  }

  String _vehicleLabel(dynamic vehicle) {
    if (vehicle == null) return '—';
    final v = vehicle as Map;
    final emoji = () {
      final t = v['type']?.toString().toLowerCase() ?? '';
      if (t.contains('suv') || t.contains('mpv')) return '🚙';
      if (t.contains('truck')) return '🛻';
      if (t.contains('van')) return '🚐';
      return '🚗';
    }();
    final brand = v['brand'] ?? '';
    final model = v['model'] ?? '';
    final plate = v['plate_number'] ?? '';
    return '$emoji $brand $model · $plate'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final carwashName =
        (item['carwashes'] as Map?)?['name']?.toString() ?? '—';
    final status = item['status']?.toString() ?? 'Pending';
    final date = _formatDate(item['schedule']);
    final services = _serviceNames(item['bookingservices']);
    final vehicleLabel = _vehicleLabel(item['vehicles']);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: date + carwash name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              Text(
                carwashName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.splash,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Service names
          Text(
            services,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontHeading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 2),

          // Vehicle
          Text(
            vehicleLabel,
            style:
                const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 8),

          // Bottom row: status badge (NEW) + booking ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ FIX: Status badge — was missing entirely
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ),
              Text(
                '#${item['booking_id']}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}