import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUsecase {
  final BookingRepository repository;

  const CreateBookingUsecase(this.repository);

  Future<BookingEntity> call({
    required String carwashId,
    required String vehicleId,
    required DateTime schedule,
    required List<String> serviceIds,
  }) {
    return repository.createBooking(
      carwashId: carwashId,
      vehicleId: vehicleId,
      schedule: schedule,
      serviceIds: serviceIds,
    );
  }
}