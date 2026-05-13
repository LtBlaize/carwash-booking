// lib/features/booking/data/models/booking_model.dart

import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.bookingId,
    required super.userId,
    required super.carwashId,
    required super.vehicleId,
    required super.vehicleSize,
    required super.schedule,
    required super.status,
    super.serviceIds,
  });

  factory BookingModel.fromMap(
    Map<String, dynamic> map, {
    List<String> serviceIds = const [],
  }) {
    return BookingModel(
      bookingId: map['booking_id'] as int,
      userId: map['user_id'].toString(),
      carwashId: map['carwash_id'].toString(),
      vehicleId: map['vehicle_id'] as int,
      vehicleSize: map['vehicle_size'].toString(),
      schedule: DateTime.parse(map['schedule'] as String),
      status: map['status'] as String? ?? 'Pending',
      serviceIds: serviceIds,
    );
  }

  Map<String, dynamic> toMap() => {
        'booking_id': bookingId,
        'user_id': userId,
        'carwash_id': carwashId,
        'vehicle_id': vehicleId,
        'vehicle_size': vehicleSize,
        'schedule': schedule.toIso8601String(),
        'status': status,
      };
}