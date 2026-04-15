import 'package:supabase_flutter/supabase_flutter.dart';

class CarwashService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCarwashes() async {
    final response = await supabase
        .from('carwashes')
        .select()
        .eq('status', 'Open');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getUpcomingBookings() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final now = DateTime.now().toIso8601String();

    final response = await supabase
        .from('bookings')
        .select('''
          *,
          carwashes (
            name
          )
        ''')
        .eq('user_id', userId)
        .eq('status', 'confirmed')
        .gte('schedule', now)
        .order('schedule', ascending: true)
        .limit(1);

    return List<Map<String, dynamic>>.from(response);
  }
}