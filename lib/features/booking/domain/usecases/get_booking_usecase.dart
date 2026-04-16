import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingHistoryUsecase {
  final BookingRepository repository;

  const GetBookingHistoryUsecase(this.repository);

  Future<List<BookingEntity>> call() => repository.getBookingHistory();
}