import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import 'api_service.dart';

class BookingService extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;

  Future<bool> saveLogic1({required String vehicleId, required String serviceType, required String date, required String time, required String address, required int price}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/bookings', {'type': BookingType.mobile.name, 'vehicleId': vehicleId, 'serviceType': serviceType, 'date': date, 'time': time, 'address': address, 'price': price});
      final newBooking = BookingModel.fromJson(response['booking']);
      _bookings.add(newBooking);
      _currentBooking = newBooking;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final newBooking = BookingModel(id: DateTime.now().millisecondsSinceEpoch.toString(), type: BookingType.mobile, vehicleId: vehicleId, serviceType: serviceType, date: date, time: time, address: address, price: price, status: BookingStatus.pending, createdAt: DateTime.now());
      _bookings.add(newBooking);
      _currentBooking = newBooking;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> saveLogic2({required String vehicleId, required String serviceType, required String date, required String time, required String washLocation, required int price}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/bookings', {'type': BookingType.partner.name, 'vehicleId': vehicleId, 'serviceType': serviceType, 'date': date, 'time': time, 'washLocation': washLocation, 'price': price});
      final newBooking = BookingModel.fromJson(response['booking']);
      _bookings.add(newBooking);
      _currentBooking = newBooking;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final newBooking = BookingModel(id: DateTime.now().millisecondsSinceEpoch.toString(), type: BookingType.partner, vehicleId: vehicleId, serviceType: serviceType, date: date, time: time, washLocation: washLocation, price: price, status: BookingStatus.pending, createdAt: DateTime.now());
      _bookings.add(newBooking);
      _currentBooking = newBooking;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  List<BookingModel> getRecentBookings({int limit = 3}) {
    final sorted = List<BookingModel>.from(_bookings)..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return sorted.take(limit).toList();
  }

  void clearBookings() {
    _bookings = [];
    _currentBooking = null;
    notifyListeners();
  }
}

