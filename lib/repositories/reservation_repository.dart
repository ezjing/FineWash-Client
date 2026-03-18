import '../repositories/api_client.dart';

class ReservationRepository {
  // ReservationController.SearchLogic1: 예약 목록 조회
  Future<Map<String, dynamic>> searchLogic1() {
    return ApiClient.get('/reservations');
  }

  // ReservationController.SearchLogic2: 예약 상세 조회
  Future<Map<String, dynamic>> searchLogic2(int resvIdx) {
    return ApiClient.get('/reservations/$resvIdx');
  }

  // ReservationController.SaveLogic1: 예약 생성
  Future<Map<String, dynamic>> saveLogic1(Map<String, dynamic> body) {
    return ApiClient.post('/reservations', body);
  }

  // ReservationController.SaveLogic2: 예약 취소
  Future<Map<String, dynamic>> saveLogic2(int resvIdx) {
    return ApiClient.put('/reservations/$resvIdx/cancel', {});
  }

  Future<Map<String, dynamic>> approveReservation(
    int resvIdx, {
    required String date,
    required String time,
    String? estimatedDuration,
  }) {
    return ApiClient.put('/reservations/$resvIdx/approve', {
      'date': date,
      'time': time,
      if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
    });
  }

  Future<Map<String, dynamic>> rejectReservation(int resvIdx) {
    return ApiClient.put('/reservations/$resvIdx/reject', {});
  }
}

