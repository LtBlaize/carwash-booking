// lib/features/booking/presentation/controllers/booking_controllers.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../../domain/usecases/get_booking_usecase.dart';

class BookingController extends ChangeNotifier {
  final CreateBookingUsecase createBookingUsecase;
  final GetBookingHistoryUsecase getBookingHistoryUsecase;

  BookingController({
    required this.createBookingUsecase,
    required this.getBookingHistoryUsecase,
  });

  bool _isLoading = false;
  String? _error;
  List<BookingEntity> _history = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingEntity> get history => _history;

  Future<BookingEntity?> createBooking({
    required String carwashId,
    required int vehicleId,
    required String vehicleSize,
    required DateTime schedule,
    required List<String> serviceIds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final booking = await createBookingUsecase(
        carwashId: carwashId,
        vehicleId: vehicleId,
        vehicleSize: vehicleSize,
        schedule: schedule,
        serviceIds: serviceIds,
      );
      return booking;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _history = await getBookingHistoryUsecase();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}