import 'package:flutter/foundation.dart';
import '../models/vehicle_model.dart';
import '../repositories/vehicle_repository.dart';

class VehicleService extends ChangeNotifier {
  final VehicleRepository _vehicleRepository = VehicleRepository();

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  bool get hasVehicles => _vehicles.isNotEmpty;

  // 차량 목록 조회 (SearchLogic1)
  Future<bool> searchLogic1() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _vehicleRepository.searchLogic1();
      if (response['success'] == true && response['vehicles'] != null) {
        _vehicles = (response['vehicles'] as List)
            .map((v) => VehicleModel.fromJson(v))
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
      // 에러 로깅 (디버깅용)
      debugPrint('차량 목록 조회 실패: $e');
      return false;
    }
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
      final response = await _vehicleRepository.saveLogic1({
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

  // 차량 수정 (SaveLogic2)
  Future<bool> saveLogic2({
    required int vehIdx,
    String? vehicleType,
    String? model,
    String? vehicleNumber,
    String? color,
    int? year,
    String? remark,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _vehicleRepository.saveLogic2(vehIdx, {
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (model != null) 'model': model,
        if (vehicleNumber != null) 'vehicle_number': vehicleNumber,
        if (color != null) 'color': color,
        if (year != null) 'year': year,
        if (remark != null) 'remark': remark,
      });

      if (response['success'] == true && response['vehicle'] != null) {
        final updated = VehicleModel.fromJson(response['vehicle']);
        final index = _vehicles.indexWhere((v) => v.vehIdx == vehIdx);
        if (index != -1) {
          _vehicles[index] = updated;
        } else {
          _vehicles.insert(0, updated);
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
      debugPrint('차량 수정 실패: $e');
      return false;
    }
  }

  // 차량 삭제 (SaveLogic3)
  Future<bool> saveLogic3(int vehIdx) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _vehicleRepository.saveLogic3(vehIdx);
      if (response['success'] == true) {
        _vehicles.removeWhere((v) => v.vehIdx == vehIdx);
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
      debugPrint('차량 삭제 실패: $e');
      return false;
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
