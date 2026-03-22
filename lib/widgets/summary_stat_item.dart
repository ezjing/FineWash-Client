import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// 카드 하단 통계 영역 (아이콘 + 라벨 + 값)
class SummaryStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SummaryStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
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
