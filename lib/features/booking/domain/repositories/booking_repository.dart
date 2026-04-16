import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBooking({
    required String carwashId,
    required String vehicleId,
    required DateTime schedule,
    required List<String> serviceIds,
  });

  Future<List<BookingEntity>> getBookingHistory();
}