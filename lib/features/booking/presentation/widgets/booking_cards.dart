// lib/features/booking/presentation/widgets/booking_cards.dart

import 'package:flutter/material.dart';
import '/core/theme/app_theme.dart';

// ─── Vehicle Card ─────────────────────────────────────────────────────────────

class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final String label;
  final String emoji;
  final String info;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                color:
                    isSelected ? AppColors.splash : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.splash : AppColors.border,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Service Card ─────────────────────────────────────────────────────────────

class ServiceCard extends StatelessWidget {
  final String name;
  final String description;
  final String duration;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  color: isSelected ? AppColors.emerald : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected ? AppColors.emerald : AppColors.border,
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