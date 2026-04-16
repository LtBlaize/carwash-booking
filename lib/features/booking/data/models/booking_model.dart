import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.carwashId,
    required super.vehicleId,
    required super.schedule,
    required super.status,
    super.serviceIds,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      carwashId: map['carwash_id'].toString(),
      vehicleId: map['vehicle_id'].toString(),
      schedule: DateTime.parse(map['schedule'] as String),
      status: map['status'] as String? ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'carwash_id': carwashId,
        'vehicle_id': vehicleId,
        'schedule': schedule.toIso8601String(),
        'status': status,
      };
}