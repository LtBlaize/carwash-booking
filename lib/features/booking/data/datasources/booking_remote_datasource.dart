// lib/features/booking/data/datasources/booking_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDatasource {
  Future<BookingModel> createBooking({
    required String carwashId,
    required int vehicleId,
    required String vehicleSize,
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
    required int vehicleId,
    required String vehicleSize,
    required DateTime schedule,
    required List<String> serviceIds,
  }) async {
    final user = _client.auth.currentUser!;

    // 1. Insert the booking row and get back the full row.
    final bookingRow = await _client
        .from('bookings')
        .insert({
          'user_id': user.id,
          'carwash_id': carwashId,
          'vehicle_id': vehicleId,       // int — matches schema
          'vehicle_size': vehicleSize,   // FK → sizes.size_id
          'schedule': schedule.toIso8601String(),
          'status': 'Pending',
        })
        .select()
        .single();

    final bookingId = bookingRow['booking_id'] as int;

    // 2. Insert one row per service into bookingservices (no underscore).
    for (final serviceId in serviceIds) {
      await _client.from('bookingservices').insert({
        'booking_id': bookingId,
        'service_id': serviceId,
      });
    }

    // 3. Return the model, attaching the service IDs we just wrote.
    return BookingModel.fromMap(bookingRow, serviceIds: serviceIds);
  }

  @override
  Future<List<BookingModel>> getBookingHistory() async {
    final user = _client.auth.currentUser!;

    // Fetch bookings with their nested bookingservices so serviceIds is populated.
    final res = await _client
        .from('bookings')
        .select('''
          *,
          carwashes (name),
          vehicles (brand, model, plate_number),
          bookingservices (service_id)
        ''')
        .eq('user_id', user.id)
        .order('schedule', ascending: false);

    return List<Map<String, dynamic>>.from(res).map((row) {
      final rawServices =
          List<Map<String, dynamic>>.from(row['bookingservices'] as List? ?? []);
      final serviceIds =
          rawServices.map((s) => s['service_id'].toString()).toList();
      return BookingModel.fromMap(row, serviceIds: serviceIds);
    }).toList();
  }
}