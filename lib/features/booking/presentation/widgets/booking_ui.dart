// lib/features/booking/presentation/widgets/booking_ui.dart

import 'package:flutter/material.dart';
import '/core/theme/app_theme.dart';

// ─── Progress Bar ─────────────────────────────────────────────────────────────

class BookingProgressBar extends StatelessWidget {
  final bool hasVehicle;
  final bool hasService;
  final bool hasTime;

  const BookingProgressBar({
    super.key,
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
                        color:
                            done ? AppColors.emerald : AppColors.border,
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.splash),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking Step Wrapper ─────────────────────────────────────────────────────

class BookingStep extends StatelessWidget {
  final String stepNum;
  final String title;
  final Widget child;
  final bool isComplete;

  const BookingStep({
    super.key,
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
                    color: isComplete
                        ? AppColors.emerald
                        : AppColors.splash,
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

// ─── Booking Summary ──────────────────────────────────────────────────────────

class BookingSummary extends StatelessWidget {
  final Set<int> selectedServices;
  final List<Map<String, dynamic>> services;
  final double total;
  final String date;
  final String? timeSlot;

  const BookingSummary({
    super.key,
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
      final mins =
          (services[i]['services'] as Map?)?['duration_minutes'];
      totalMinutes += int.tryParse(mins?.toString() ?? '0') ?? 0;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.splash50,
        border:
            Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
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
            final price =
                '₱${(services[i]['price'] as num?)?.toStringAsFixed(0) ?? '0'}';
            return SummaryRow(name, price);
          }),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFBAE6FD), height: 16),
          if (timeSlot != null)
            SummaryRow('📅  $date at $timeSlot', ''),
          if (totalMinutes > 0)
            SummaryRow('⏱️  Est. duration', '$totalMinutes min'),
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
                '₱${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.splash,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Summary Row ──────────────────────────────────────────────────────────────

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRow(this.label, this.value, {super.key});

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

// ─── Loading Placeholder ──────────────────────────────────────────────────────

class BookingLoadingPlaceholder extends StatelessWidget {
  const BookingLoadingPlaceholder({super.key});

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

// ─── Empty State ──────────────────────────────────────────────────────────────

class BookingEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BookingEmptyState({
    super.key,
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
              style: const TextStyle(
                  fontSize: 12, color: AppColors.muted)),
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

// ─── Validation Hints ─────────────────────────────────────────────────────────

class ValidationHints extends StatelessWidget {
  final bool hasVehicle;
  final bool hasService;
  final bool hasTime;

  const ValidationHints({
    super.key,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: const Color(0xFFFDBA74), width: 1),
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

// ─── Slot Legend ──────────────────────────────────────────────────────────────

class SlotLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool strikethrough;

  const SlotLegend({
    super.key,
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