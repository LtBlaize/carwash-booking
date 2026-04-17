import 'package:flutter/material.dart';
import '../../domain/entities/carwash_location_entity.dart';

/// Custom marker widget — rendered to BitmapDescriptor via
/// WidgetToMarkerBitmap if needed, or used as an overlay.
class CarwashMarkerWidget extends StatelessWidget {
  final CarwashLocationEntity carwash;
  final bool isSelected;

  const CarwashMarkerWidget({
    super.key,
    required this.carwash,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1D4ED8) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isSelected
              ? const Color(0xFF1D4ED8)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🚿', style: TextStyle(fontSize: isSelected ? 14 : 12)),
          const SizedBox(width: 4),
          Text(
            carwash.name.length > 12
                ? '${carwash.name.substring(0, 12)}…'
                : carwash.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}