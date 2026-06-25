import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 예약 요약·결제 정보 등 라벨-값 한 줄 행
class SummaryLabelValueRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryLabelValueRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
