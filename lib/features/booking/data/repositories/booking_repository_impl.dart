// lib/features/booking/data/repositories/booking_repository_impl.dart

import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource datasource;

  BookingRepositoryImpl(this.datasource);

  @override
  Future<BookingEntity> createBooking({
    required String carwashId,
    required int vehicleId,
    required String vehicleSize,
    required DateTime schedule,
    required List<String> serviceIds,
  }) =>
      datasource.createBooking(
        carwashId: carwashId,
        vehicleId: vehicleId,
        vehicleSize: vehicleSize,
        schedule: schedule,
        serviceIds: serviceIds,
      );

  @override
  Future<List<BookingEntity>> getBookingHistory() =>
      datasource.getBookingHistory();
}