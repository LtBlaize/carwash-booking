// lib/features/home/data/carwash_service.dart
//
// Moved from features/auth/ — this service has nothing to do with auth.
// It fetches carwash listings and upcoming bookings for the home screen.

import 'package:supabase_flutter/supabase_flutter.dart';

class CarwashService {
  final _client = Supabase.instance.client;

  /// Returns all open carwashes.
  /// Selects lat/lng so callers that render a map have coordinates.
  Future<List<Map<String, dynamic>>> getCarwashes() async {
    final response = await _client
        .from('carwashes')
        .select('carwash_id, name, status, latitude, longitude')
        .eq('status', 'Open');

    return List<Map<String, dynamic>>.from(response);
  }

  /// Returns the next upcoming booking for the current user.
  /// Status is 'Pending' — matches what book_page.dart inserts.
  Future<List<Map<String, dynamic>>> getUpcomingBookings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final now = DateTime.now().toIso8601String();

    final response = await _client
        .from('bookings')
        .select('''
          booking_id,
          schedule,
          status,
          carwashes (name)
        ''')
        .eq('user_id', userId)
        .inFilter('status', ['Pending', 'Confirmed'])
        .gte('schedule', now)
        .order('schedule', ascending: true)
        .limit(1);

    return List<Map<String, dynamic>>.from(response);
  }
}