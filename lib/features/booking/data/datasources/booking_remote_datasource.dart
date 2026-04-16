import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDatasource {
  Future<BookingModel> createBooking({
    required String carwashId,
    required String vehicleId,
    required DateTime schedule,
    required List<String> serviceIds,
  });

  Future<List<BookingModel>> getBookingHistory();
}

class BookingRemoteDatasourceImpl implements BookingRemoteDatasource {
  final SupabaseClient _client;

  BookingRemoteDatasourceImpl(this._client);

  @override
  Future<BookingModel> createBooking({
    required String carwashId,
    required String vehicleId,
    required DateTime schedule,
    required List<String> serviceIds,
  }) async {
    final user = _client.auth.currentUser!;

    final bookingRes = await _client
        .from('bookings')
        .insert({
          'user_id': user.id,
          'carwash_id': carwashId,
          'vehicle_id': vehicleId,
          'schedule': schedule.toIso8601String(),
          'status': 'Pending',
        })
        .select()
        .single();

    final bookingId = bookingRes['id'];
    for (final serviceId in serviceIds) {
      await _client.from('booking_services').insert({
        'booking_id': bookingId,
        'service_id': serviceId,
      });
    }

    return BookingModel.fromMap(bookingRes);
  }

  @override
  Future<List<BookingModel>> getBookingHistory() async {
    final user = _client.auth.currentUser!;
    final res = await _client
        .from('bookings')
        .select('*, carwashes(name), vehicles(brand, model, plate_number)')
        .eq('user_id', user.id)
        .order('schedule', ascending: false);

    return List<Map<String, dynamic>>.from(res)
        .map(BookingModel.fromMap)
        .toList();
  }
}