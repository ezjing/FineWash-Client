import 'package:flutter/foundation.dart';
import '../models/vehicle_model.dart';
import 'api_service.dart';

class VehicleService extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  bool get hasVehicles => _vehicles.isNotEmpty;

  // 차량 목록 조회 (SearchLogic1)
  Future<void> searchLogic1() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/vehicles');
      if (response['success'] == true && response['vehicles'] != null) {
        _vehicles = (response['vehicles'] as List)
            .map((v) => VehicleModel.fromJson(v))
            .toList();
      }
    } catch (e) {
      // 오프라인 모드
    }
    _isLoading = false;
    notifyListeners();
  }

  // 차량 등록 (SaveLogic1)
  Future<bool> saveLogic1({
    required String vehicleType,
    required String model,
    required String vehicleNumber,
    String? color,
    int? year,
    String? remark,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/vehicles', {
        'vehicle_type': vehicleType,
        'model': model,
        'vehicle_number': vehicleNumber,
        'color': color,
        'year': year,
        'remark': remark,
      });
      if (response['success'] == true && response['vehicle'] != null) {
        final newVehicle = VehicleModel.fromJson(response['vehicle']);
        _vehicles.add(newVehicle);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final newVehicle = VehicleModel(
        vehIdx: DateTime.now().millisecondsSinceEpoch,
        vehicleType: vehicleType,
        model: model,
        vehicleNumber: vehicleNumber,
        color: color,
        year: year,
        remark: remark,
      );
      _vehicles.add(newVehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  VehicleModel? getVehicleById(int vehIdx) {
    try {
      return _vehicles.firstWhere((v) => v.vehIdx == vehIdx);
    } catch (e) {
      return null;
    }
  }

  void clearVehicles() {
    _vehicles = [];
    notifyListeners();
  }
}
