import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_payment.dart';
import 'package:portone_flutter/model/payment_data.dart';
import 'package:uuid/uuid.dart';
import 'api_service.dart';

class PaymentService {
  // 포트원 가맹점 식별코드 (실제 운영 시 환경변수로 관리)
  static const String _impCode = 'imp19424728';

  /// 포트원 결제 요청
  static Future<void> requestPayment({
    required BuildContext context,
    required int amount,
    required String merchantUid,
    required String name,
    required String buyerName,
    required String buyerTel,
    required String buyerEmail,
    required Function(Map<String, dynamic>) callback,
  }) async {
    final paymentData = PaymentData(
      pg: 'kcp', // PG사
      payMethod: 'card', // 결제수단
      merchantUid: merchantUid, // 주문번호
      name: name, // 상품명
      amount: amount, // 결제금액
      buyerName: buyerName, // 구매자 이름
      buyerTel: buyerTel, // 구매자 전화번호
      buyerEmail: buyerEmail, // 구매자 이메일
      appScheme: 'finewash', // 앱 URL scheme
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      callback({
                        'imp_success': 'false',
                        'error_msg': '결제가 취소되었습니다.',
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: IamportPayment(
                appBar: AppBar(
                  title: const Text('결제'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                initialChild: const Center(
                  child: CircularProgressIndicator(),
                ),
                userCode: _impCode,
                data: paymentData,
                callback: (Map<String, String> result) {
                  Navigator.pop(context);
                  // Map<String, String>을 Map<String, dynamic>으로 변환
                  final dynamicResult = <String, dynamic>{};
                  result.forEach((key, value) {
                    dynamicResult[key] = value;
                  });
                  callback(dynamicResult);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 백엔드 서버에 결제 검증 요청
  /// 
  /// [impUid] 아임포트 결제 고유번호
  /// [merchantUid] 주문 고유번호
  /// [amount] 결제 금액
  /// 
  /// Returns: 검증 성공 여부
  static Future<bool> verifyPaymentWithBackend({
    required String impUid,
    required String merchantUid,
    required int amount,
  }) async {
    try {
      final response = await ApiService.post('/payments/verify', {
        'imp_uid': impUid,
        'merchant_uid': merchantUid,
        'amount': amount,
      });
      return response['success'] == true && response['verified'] == true;
    } catch (e) {
      // 백엔드 검증 실패 시 false 반환
      debugPrint('결제 검증 실패: $e');
      return false;
    }
  }

  /// 주문 고유번호 생성
  static String generateMerchantUid() {
    const uuid = Uuid();
    return 'reservation_${uuid.v4()}';
  }

  /// 결제 결과 검증
  /// 
  /// 클라이언트 측 기본 검증만 수행
  /// 실제 결제 검증은 백엔드 서버에서 수행해야 함
  static bool verifyPaymentResult(Map<String, dynamic> result) {
    // portone_flutter는 imp_success를 String으로 반환
    final success = result['imp_success'] == 'true' || result['imp_success'] == true;
    final errorCode = result['error_code'];
    
    return success && (errorCode == null || errorCode.toString().isEmpty);
  }
}
