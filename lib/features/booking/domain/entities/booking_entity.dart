// lib/features/booking/domain/entities/booking_entity.dart

class BookingEntity {
  final int bookingId;
  final String userId;
  final String carwashId;
  final int vehicleId;
  final String vehicleSize;
  final DateTime schedule;
  final String status;
  final List<String> serviceIds;

  const BookingEntity({
    required this.bookingId,
    required this.userId,
    required this.carwashId,
    required this.vehicleId,
    required this.vehicleSize,
    required this.schedule,
    required this.status,
    this.serviceIds = const [],
  });
}