import 'package:flutter/material.dart';

class MapRecenterButton extends StatelessWidget {
  final VoidCallback? onTap; // ← nullable

  const MapRecenterButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDisabled ? 0.05 : 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.my_location_rounded,
          size: 20,
          // ← grayed out when location is denied
          color: isDisabled
              ? const Color(0xFFCBD5E1)
              : const Color(0xFF1D4ED8),
        ),
      ),
    );
  }
}

class MapFilterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const MapFilterButton({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1D4ED8) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: isActive ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }
}