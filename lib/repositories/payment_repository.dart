import '../repositories/api_client.dart';

class PaymentRepository {
  // PaymentController.SaveLogic1: 결제 검증
  Future<Map<String, dynamic>> saveLogic1({
    required String impUid,
    required String merchantUid,
    required int amount,
  }) {
    return ApiClient.post('/payments/verify', {
      'imp_uid': impUid,
      'merchant_uid': merchantUid,
      'amount': amount,
    });
  }
}
