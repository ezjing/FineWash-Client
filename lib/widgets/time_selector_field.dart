import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 스케줄·예약 화면 공통 시간 선택 필드
class TimeSelectorField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final String placeholder;
  final double valueFontSize;

  const TimeSelectorField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = '시간 선택',
    this.valueFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == placeholder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.w500,
                color: isPlaceholder
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
