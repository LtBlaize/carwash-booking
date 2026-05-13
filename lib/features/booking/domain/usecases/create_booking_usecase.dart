// lib/features/booking/domain/usecases/create_booking_usecase.dart

import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUsecase {
  final BookingRepository repository;

  const CreateBookingUsecase(this.repository);

  Future<BookingEntity> call({
    required String carwashId,
    required int vehicleId,
    required String vehicleSize,
    required DateTime schedule,
    required List<String> serviceIds,
  }) {
    return repository.createBooking(
      carwashId: carwashId,
      vehicleId: vehicleId,
      vehicleSize: vehicleSize,
      schedule: schedule,
      serviceIds: serviceIds,
    );
  }
}