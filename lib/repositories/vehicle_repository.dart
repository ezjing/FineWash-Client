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

  // VehicleController.SaveLogic2: 차량 수정
  Future<Map<String, dynamic>> saveLogic2(int vehIdx, Map<String, dynamic> body) {
    return ApiClient.put('/vehicles/$vehIdx', body);
  }

  // VehicleController.SaveLogic3: 차량 삭제
  Future<Map<String, dynamic>> saveLogic3(int vehIdx) {
    return ApiClient.delete('/vehicles/$vehIdx');
  }
}
