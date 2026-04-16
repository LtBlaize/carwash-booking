class BookingEntity {
  final String id;
  final String userId;
  final String carwashId;
  final String vehicleId;
  final DateTime schedule;
  final String status;
  final List<String> serviceIds;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.carwashId,
    required this.vehicleId,
    required this.schedule,
    required this.status,
    this.serviceIds = const [],
  });
}