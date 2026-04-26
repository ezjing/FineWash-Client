import '../repositories/api_client.dart';

class BusinessRepository {
  // BusinessController.SearchLogic1: 룸(DTL) 상세 조회 - 해당 룸 정보 + 예약 목록
  Future<Map<String, dynamic>> searchLogic1(int busDtlIdx) {
    return ApiClient.get('/businesses/rooms/$busDtlIdx');
  }

  // BusinessController.SearchLogic2: 사업장 목록 조회
  Future<Map<String, dynamic>> searchLogic2() {
    return ApiClient.get('/businesses');
  }

  // BusinessController.SearchLogic3: 사업장 상세 조회
  Future<Map<String, dynamic>> searchLogic3(int busMstIdx) {
    return ApiClient.get('/businesses/$busMstIdx');
  }

  // BusinessController.SearchLogic4: 좌표 기반 거리순 사업장 목록 조회
  // 예: GET `/businesses/nearby?lat=...&lng=...`
  Future<Map<String, dynamic>> searchLogic4({
    required double latitude,
    required double longitude,
  }) {
    final lat = Uri.encodeComponent(latitude.toString());
    final lng = Uri.encodeComponent(longitude.toString());
    return ApiClient.get('/businesses/nearby?lat=$lat&lng=$lng');
  }

  // BusinessController.SaveLogic1: 사업장(MST) 등록
  Future<Map<String, dynamic>> saveLogic1(Map<String, dynamic> body) {
    return ApiClient.post('/businesses', body);
  }

  // BusinessController.SaveLogic2: 사업장(MST) 수정
  Future<Map<String, dynamic>> saveLogic2(
    int busMstIdx,
    Map<String, dynamic> body,
  ) {
    return ApiClient.put('/businesses/$busMstIdx', body);
  }

  // BusinessController.SaveLogic3: 룸(DTL) 추가
  Future<Map<String, dynamic>> saveLogic3(Map<String, dynamic> body) {
    return ApiClient.post('/businesses/rooms', body);
  }

  // BusinessController.SaveLogic4: 룸(DTL) 수정
  Future<Map<String, dynamic>> saveLogic4(
    int busDtlIdx,
    Map<String, dynamic> body,
  ) {
    return ApiClient.put('/businesses/rooms/$busDtlIdx', body);
  }

  // BusinessController.SaveLogic5: 룸(DTL) 삭제
  Future<Map<String, dynamic>> saveLogic5(int busDtlIdx) {
    return ApiClient.delete('/businesses/rooms/$busDtlIdx');
  }

  // BusinessController.SaveLogic6: 사업장(MST) 삭제
  Future<Map<String, dynamic>> saveLogic6(int busMstIdx) {
    return ApiClient.delete('/businesses/$busMstIdx');
  }
}

