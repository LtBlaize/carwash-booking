import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  int _selectedVehicle = 0;
  final Set<int> _selectedServices = {0, 1};
  int _selectedTimeSlot = 2;

  final _vehicles = [
    {'emoji': '🚗', 'name': 'Toyota Vios 2020', 'info': 'ABC-1234 · Sedan · Medium · White'},
    {'emoji': '🚙', 'name': 'Mitsubishi Xpander 2023', 'info': 'DEF-5678 · SUV · Large · Black'},
  ];

  final _services = [
    {'name': 'Basic Wash', 'dur': '30 min', 'price': '₱200', 'amount': 200},
    {'name': 'Tire & Rim Shine', 'dur': '10 min', 'price': '₱120', 'amount': 120},
    {'name': 'Wax & Polish', 'dur': '30 min', 'price': '₱450', 'amount': 450},
    {'name': 'Interior Vacuum', 'dur': '15 min', 'price': '₱150', 'amount': 150},
  ];

  final _slots = [
    {'label': '8:00 AM', 'avail': true},
    {'label': '8:30', 'avail': false},
    {'label': '9:00 AM', 'avail': true},
    {'label': '9:30', 'avail': true},
    {'label': '10:00', 'avail': true},
    {'label': '10:30', 'avail': true},
    {'label': '11:00', 'avail': false},
    {'label': '11:30', 'avail': true},
    {'label': '1:00 PM', 'avail': true},
    {'label': '1:30', 'avail': true},
    {'label': '2:00', 'avail': true},
    {'label': '2:30', 'avail': true},
  ];

  int get _total {
    int sum = 0;
    for (final i in _selectedServices) {
      sum += _services[i]['amount'] as int;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const SplashAppBar(),
      body: ListView(
        children: [
          // Booking header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Book at AquaShine — Makati',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Select vehicle, services, and preferred time',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Step 1: Vehicle
          _BookingStep(
            stepNum: '1',
            title: 'Select Vehicle',
            child: Column(
              children: List.generate(_vehicles.length, (i) {
                final v = _vehicles[i];
                final sel = _selectedVehicle == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.splash50 : Colors.white,
                      border: Border.all(
                        color: sel ? AppColors.splash : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(v['emoji']!,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v['name']!,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontHeading,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                              Text(
                                v['info']!,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: sel ? AppColors.splash : Colors.transparent,
                            border: Border.all(
                              color:
                                  sel ? AppColors.splash : AppColors.border,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: sel
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 12)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step 2: Services
          _BookingStep(
            stepNum: '2',
            title: 'Select Services',
            child: Column(
              children: List.generate(_services.length, (i) {
                final s = _services[i];
                final sel = _selectedServices.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      _selectedServices.remove(i);
                    } else {
                      _selectedServices.add(i);
                    }
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFF0FDF4)
                          : Colors.white,
                      border: Border.all(
                        color: sel
                            ? AppColors.emerald
                            : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.emerald
                                : Colors.transparent,
                            border: Border.all(
                              color: sel
                                  ? AppColors.emerald
                                  : AppColors.border,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: sel
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 12)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'] as String,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontHeading,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              Text(
                                s['dur'] as String,
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          s['price'] as String,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontHeading,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step 3: Time slots
          _BookingStep(
            stepNum: '3',
            title: 'Pick a Time — Sat, Mar 29',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 2.4,
              ),
              itemCount: _slots.length,
              itemBuilder: (_, i) {
                final slot = _slots[i];
                final avail = slot['avail'] as bool;
                final sel = _selectedTimeSlot == i && avail;
                return GestureDetector(
                  onTap: avail
                      ? () => setState(() => _selectedTimeSlot = i)
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? AppColors.splash : Colors.white,
                      border: Border.all(
                        color: sel
                            ? AppColors.splash
                            : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      slot['label'] as String,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontHeading,
                        fontSize: 11,
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
          ),

          // Booking summary
          _BookingSummary(selectedServices: _selectedServices, services: _services, total: _total),

          // Book button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: GestureDetector(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.splash,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '📅  Book Appointment',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
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

  const _BookingStep({
    required this.stepNum,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.splash,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNum,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontHeading,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  final Set<int> selectedServices;
  final List<Map<String, Object>> services;
  final int total;

  const _BookingSummary({
    required this.selectedServices,
    required this.services,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.splash50,
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ...selectedServices.map((i) => _SummaryRow(
                services[i]['name'] as String,
                services[i]['price'] as String,
              )),
          const _SummaryRow('Saturday, Mar 29 at 9:00 AM', ''),
          const _SummaryRow('Est. duration', '40 min'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Color(0xFFBAE6FD),
                    style: BorderStyle.solid),
              ),
            ),
            child: Row(
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
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '✨ +32 points earned · Gold member discount applied',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.emerald,
              ),
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
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.body)),
          Text(value,
              style: const TextStyle(fontSize: 12, color: AppColors.body)),
        ],
      ),
    );
  }
}