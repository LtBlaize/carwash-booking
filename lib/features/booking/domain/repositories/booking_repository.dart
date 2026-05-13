// lib/features/booking/domain/repositories/booking_repository.dart

import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String carwashId,
    required int vehicleId,
    required String vehicleSize,
    required DateTime schedule,
    required List<String> serviceIds,
  });

  Future<List<BookingEntity>> getBookingHistory();
}