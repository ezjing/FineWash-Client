import 'package:flutter/foundation.dart';
import '../models/reservation_model.dart';
import 'api_service.dart';

class ReservationService extends ChangeNotifier {
  List<ReservationModel> _reservations = [];
  ReservationModel? _currentReservation;
  bool _isLoading = false;

  List<ReservationModel> get reservations => _reservations;
  ReservationModel? get currentReservation => _currentReservation;
  bool get isLoading => _isLoading;

  // 예약 목록 조회 (SearchLogic1)
  Future<bool> searchLogic1() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/reservations');
      if (response['success'] == true && response['reservations'] != null) {
        _reservations = (response['reservations'] as List)
            .map((json) => ReservationModel.fromJson(json))
            .toList();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 예약 생성 (SaveLogic1 - 출장세차)
  Future<bool> saveLogic1({
    required int vehicleId,
    required String mainOption,
    String? midOption,
    String? subOption,
    required String date,
    required String time,
    required String vehicleLocation,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/reservations', {
        'vehicleId': vehicleId,
        'main_option': mainOption,
        'mid_option': midOption,
        'sub_option': subOption,
        'date': date,
        'time': time,
        'vehicle_location': vehicleLocation,
      });
      if (response['success'] == true && response['reservation'] != null) {
        final newReservation = ReservationModel.fromJson(
          response['reservation'],
        );
        _reservations.add(newReservation);
        _currentReservation = newReservation;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 예약 생성 (SaveLogic2 - 제휴세차장)
  Future<bool> saveLogic2({
    required int vehicleId,
    required String mainOption,
    String? midOption,
    String? subOption,
    required String date,
    required String time,
    required int busDtlIdx,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/reservations', {
        'vehicleId': vehicleId,
        'main_option': mainOption,
        'mid_option': midOption,
        'sub_option': subOption,
        'date': date,
        'time': time,
        'bus_dtl_idx': busDtlIdx,
      });
      if (response['success'] == true && response['reservation'] != null) {
        final newReservation = ReservationModel.fromJson(
          response['reservation'],
        );
        _reservations.add(newReservation);
        _currentReservation = newReservation;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 예약 취소
  Future<bool> cancelReservation(int resvIdx) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.put(
        '/reservations/$resvIdx/cancel',
        {},
      );
      if (response['success'] == true) {
        final index = _reservations.indexWhere((r) => r.resvIdx == resvIdx);
        if (index != -1) {
          _reservations[index] = ReservationModel.fromJson(
            response['reservation'],
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<ReservationModel> getRecentReservations({int limit = 3}) {
    final sorted = List<ReservationModel>.from(_reservations)
      ..sort(
        (a, b) => (b.createdDate ?? DateTime.now()).compareTo(
          a.createdDate ?? DateTime.now(),
        ),
      );
    return sorted.take(limit).toList();
  }

  void clearReservations() {
    _reservations = [];
    _currentReservation = null;
    notifyListeners();
  }
}
