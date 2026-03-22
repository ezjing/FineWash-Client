import 'api_client.dart';

/// WashOptionController — SearchLogic1(MST 목록), SaveLogic1~4, DeleteLogic1~2
class WashOptionRepository {
  /// GET `/wash-options/masters?busMstIdx=`
  Future<Map<String, dynamic>> searchLogic1({required int busMstIdx}) {
    return ApiClient.get('/wash-options/masters?busMstIdx=$busMstIdx');
  }

  /// POST `/wash-options/masters`
  Future<Map<String, dynamic>> saveLogic1(Map<String, dynamic> body) {
    return ApiClient.post('/wash-options/masters', body);
  }

  /// PUT `/wash-options/masters/:woptMstIdx`
  Future<Map<String, dynamic>> saveLogic2(
    int woptMstIdx,
    Map<String, dynamic> body,
  ) {
    return ApiClient.put('/wash-options/masters/$woptMstIdx', body);
  }

  /// DELETE `/wash-options/masters/:woptMstIdx`
  Future<Map<String, dynamic>> deleteLogic1(int woptMstIdx) {
    return ApiClient.delete('/wash-options/masters/$woptMstIdx');
  }

  /// POST `/wash-options/details`
  Future<Map<String, dynamic>> saveLogic3(Map<String, dynamic> body) {
    return ApiClient.post('/wash-options/details', body);
  }

  /// PUT `/wash-options/details/:woptDtlIdx`
  Future<Map<String, dynamic>> saveLogic4(
    int woptDtlIdx,
    Map<String, dynamic> body,
  ) {
    return ApiClient.put('/wash-options/details/$woptDtlIdx', body);
  }

  /// DELETE `/wash-options/details/:woptDtlIdx`
  Future<Map<String, dynamic>> deleteLogic2(int woptDtlIdx) {
    return ApiClient.delete('/wash-options/details/$woptDtlIdx');
  }
}
