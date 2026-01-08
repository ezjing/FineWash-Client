import 'package:flutter/material.dart';
// import 'package:iamport_flutter/iamport_payment.dart';  // 제거
// import 'package:iamport_flutter/model/payment_data.dart';  // 제거
import 'package:uuid/uuid.dart';

class PaymentService {
  // 포트원 가맹점 식별코드 (실제 운영 시 환경변수로 관리)
  static const String _impCode = 'imp19424728';

  /// 포트원 결제 요청
  ///
  /// 주의: iamport_flutter 플러그인이 제거되어 현재 비활성화됨
  /// 결제 기능이 필요하면 다른 플러그인으로 대체 필요
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
    // TODO: iamport_flutter 제거로 인해 결제 기능 비활성화
    // 결제 기능이 필요하면 다른 결제 플러그인으로 대체 필요
    callback({'imp_success': false, 'error_msg': '결제 기능이 현재 비활성화되어 있습니다.'});

    /* 기존 코드 주석 처리
    final paymentData = PaymentData(
      pg: 'kcp',
      payMethod: 'card',
      name: name,
      merchantUid: merchantUid,
      amount: amount,
      buyerName: buyerName,
      buyerTel: buyerTel,
      buyerEmail: buyerEmail,
      appScheme: 'finewash',
      niceMobileV2: true,
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
                        'imp_success': false,
                        'error_msg': '결제가 취소되었습니다.',
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: IamportPayment(
                initialChild: const Center(child: CircularProgressIndicator()),
                userCode: _impCode,
                data: paymentData,
                callback: (Map<String, dynamic> result) {
                  Navigator.pop(context);
                  callback(result);
                },
              ),
            ),
          ],
        ),
      ),
    );
    */
  }

  /// 주문 고유번호 생성
  static String generateMerchantUid() {
    const uuid = Uuid();
    return 'reservation_${uuid.v4()}';
  }

  /// 결제 결과 검증
  static bool verifyPaymentResult(Map<String, dynamic> result) {
    return result['imp_success'] == true &&
        (result['error_code'] == null ||
            result['error_code'].toString().isEmpty);
  }
}
