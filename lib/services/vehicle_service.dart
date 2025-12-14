import 'package:flutter/foundation.dart';
import '../models/vehicle_model.dart';
import 'api_service.dart';

class VehicleService extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  bool get hasVehicles => _vehicles.isNotEmpty;

  Future<void> searchLogic1() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/vehicles');
      _vehicles = (response['vehicles'] as List).map((v) => VehicleModel.fromJson(v)).toList();
    } catch (e) {
      // 오프라인 모드
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveLogic1({required String name, required String number, required VehicleSize size}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.post('/vehicles', {'name': name, 'number': number, 'size': size.name});
      final newVehicle = VehicleModel.fromJson(response['vehicle']);
      _vehicles.add(newVehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final newVehicle = VehicleModel(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, number: number, size: size);
      _vehicles.add(newVehicle);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  VehicleModel? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearVehicles() {
    _vehicles = [];
    notifyListeners();
  }
}

