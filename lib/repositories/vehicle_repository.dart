import '../repositories/api_client.dart';

class VehicleRepository {
  // VehicleController.SearchLogic1: 차량 목록 조회
  Future<Map<String, dynamic>> searchLogic1() {
    return ApiClient.get('/vehicles');
  }

  // VehicleController.SaveLogic1: 차량 등록
  Future<Map<String, dynamic>> saveLogic1(Map<String, dynamic> body) {
    return ApiClient.post('/vehicles', body);
  }
}
