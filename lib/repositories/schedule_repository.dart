import '../repositories/api_client.dart';

class ScheduleRepository {
  Future<Map<String, dynamic>> searchLogic1({required int busMstIdx}) {
    return ApiClient.get('/schedules/masters?busMstIdx=$busMstIdx');
  }

  Future<Map<String, dynamic>> saveLogic1(Map<String, dynamic> body) {
    return ApiClient.post('/schedules/masters', body);
  }

  Future<Map<String, dynamic>> saveLogic2(
    int schMstIdx,
    Map<String, dynamic> body,
  ) {
    return ApiClient.put('/schedules/masters/$schMstIdx', body);
  }

  Future<Map<String, dynamic>> deleteLogic1(int schMstIdx) {
    return ApiClient.delete('/schedules/masters/$schMstIdx');
  }

  Future<Map<String, dynamic>> searchLogic2({
    required int busMstIdx,
    required int year,
    required int month,
  }) {
    return ApiClient.get(
      '/schedules/details?busMstIdx=$busMstIdx&year=$year&month=$month',
    );
  }

  Future<Map<String, dynamic>> saveLogic3(Map<String, dynamic> body) {
    return ApiClient.post('/schedules/details', body);
  }

  Future<Map<String, dynamic>> saveLogic4(
    int schDtlIdx,
    Map<String, dynamic> body,
  ) {
    return ApiClient.put('/schedules/details/$schDtlIdx', body);
  }

  Future<Map<String, dynamic>> deleteLogic2(int schDtlIdx) {
    return ApiClient.delete('/schedules/details/$schDtlIdx');
  }
}
