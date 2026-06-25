import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_format_util.dart';
import '../summary_label_value_row.dart';
import 'reservation_step_config.dart';

/// 예약 Step 3 — 날짜·시간 선택 + 요약 (출장·제휴 공통)
class ReservationDateTimeStep extends StatelessWidget {
  final ReservationStepConfig config;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? midOptionName;
  final String? subOptionName;
  final int totalPrice;
  final List<String> availableTimes;
  final VoidCallback onSelectDate;
  final ValueChanged<String?> onTimeSelected;

  const ReservationDateTimeStep({
    super.key,
    required this.config,
    required this.selectedDate,
    required this.selectedTime,
    required this.midOptionName,
    required this.subOptionName,
    required this.totalPrice,
    required this.availableTimes,
    required this.onSelectDate,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final accent = config.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '날짜',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onSelectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? DateFormatUtil.toKoreanDate(selectedDate!)
                      : '날짜를 선택하세요',
                  style: TextStyle(
                    color: selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '시간',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTimes
              .map(
                (time) => ChoiceChip(
                  label: Text(time),
                  selected: selectedTime == time,
                  onSelected: (selected) =>
                      onTimeSelected(selected ? time : null),
                  selectedColor: accent.withAlpha((0.2 * 255).round()),
                  labelStyle: TextStyle(
                    color: selectedTime == time
                        ? accent
                        : AppColors.textSecondary,
                    fontWeight: selectedTime == time
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              )
              .toList(),
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
                '예약 정보 요약',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (midOptionName != null) ...[
                SummaryLabelValueRow(label: '중옵션', value: midOptionName!),
                const SizedBox(height: 8),
              ],
              if (subOptionName != null) ...[
                SummaryLabelValueRow(label: '소옵션', value: subOptionName!),
                const SizedBox(height: 8),
              ],
              SummaryLabelValueRow(
                label: '날짜',
                value: selectedDate != null
                    ? DateFormatUtil.toKoreanDate(selectedDate!)
                    : '-',
              ),
              const SizedBox(height: 8),
              SummaryLabelValueRow(
                label: '시간',
                value: selectedTime ?? '-',
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 결제 금액',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    formatWonWithSuffix(totalPrice),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
