import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _selectedFilter = 0;

  final _filters = ['All', 'AquaShine', 'SpeedyWash'];

  final _allHistory = [
    {
      'date': 'Mar 22, 2026',
      'branch': 'AquaShine Makati',
      'service': 'Basic Wash + Tire & Rim Shine',
      'vehicle': '🚗 Toyota Vios · ABC-1234 · Sedan / Medium',
      'price': '₱320',
      'points': '+32 pts',
      'rating': 5,
      'filter': 'AquaShine',
    },
    {
      'date': 'Mar 15, 2026',
      'branch': 'SpeedyWash Cebu',
      'service': 'Premium Wash',
      'vehicle': '🚙 Xpander · DEF-5678 · SUV / Large',
      'price': '₱450',
      'points': '+45 pts',
      'rating': 4,
      'filter': 'SpeedyWash',
    },
    {
      'date': 'Mar 10, 2026',
      'branch': 'AquaShine Makati',
      'service': 'Full Detailing',
      'vehicle': '🚗 Toyota Vios · ABC-1234 · Sedan / Medium',
      'price': '₱1,500',
      'points': '+150 pts',
      'rating': 5,
      'filter': 'AquaShine',
    },
    {
      'date': 'Mar 3, 2026',
      'branch': 'AquaShine Makati',
      'service': 'Basic Wash + Wax & Polish',
      'vehicle': '🚗 Toyota Vios · ABC-1234 · Sedan / Medium',
      'price': '₱580',
      'points': '+58 pts',
      'rating': 5,
      'filter': 'AquaShine',
    },
    {
      'date': 'Feb 24, 2026',
      'branch': 'SpeedyWash Cebu',
      'service': 'Basic Wash',
      'vehicle': '🚙 Xpander · DEF-5678 · SUV / Large',
      'price': '₱250',
      'points': '+25 pts',
      'rating': 4,
      'filter': 'SpeedyWash',
    },
  ];

  List<Map<String, Object>> get _filtered {
    if (_selectedFilter == 0) return _allHistory.cast();
    final label = _filters[_selectedFilter];
    return _allHistory
        .where((h) => (h['filter'] as String).contains(label))
        .toList()
        .cast();
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
          // Pill filters
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
                        color:
                            active ? Colors.white : AppColors.muted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _HistoryCard(item: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, Object> item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rating = item['rating'] as int;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['date'] as String,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              Text(
                item['branch'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.splash,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['service'] as String,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontHeading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item['vehicle'] as String,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item['price'] as String,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontHeading,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item['points'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.emerald,
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Text(
                    i < rating ? '⭐' : '☆',
                    style: const TextStyle(fontSize: 12),
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