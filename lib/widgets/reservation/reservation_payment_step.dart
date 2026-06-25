import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/reservation_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_format_util.dart';
import '../summary_label_value_row.dart';
import 'reservation_step_config.dart';

/// 예약 Step 4 — 최종 결제 확인 (출장·제휴 공통)
class ReservationPaymentStep extends StatelessWidget {
  final ReservationStepConfig config;
  final DateTime selectedDate;
  final String selectedTime;
  final String? midOptionName;
  final String? subOptionName;
  final int totalPrice;
  final VoidCallback onPay;

  const ReservationPaymentStep({
    super.key,
    required this.config,
    required this.selectedDate,
    required this.selectedTime,
    required this.midOptionName,
    required this.subOptionName,
    required this.totalPrice,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final accent = config.accentColor;

    return Consumer<ReservationService>(
      builder: (context, reservationService, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최종 결제 정보',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SummaryLabelValueRow(
                  label: '중옵션',
                  value: midOptionName ?? '-',
                ),
                const SizedBox(height: 8),
                SummaryLabelValueRow(
                  label: '소옵션',
                  value: subOptionName ?? '-',
                ),
                const SizedBox(height: 8),
                SummaryLabelValueRow(
                  label: '날짜',
                  value: DateFormatUtil.toKoreanDate(selectedDate),
                ),
                const SizedBox(height: 8),
                SummaryLabelValueRow(label: '시간', value: selectedTime),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '총 결제 금액',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      formatWonWithSuffix(totalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: reservationService.isLoading ? null : onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: reservationService.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '결제하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}
