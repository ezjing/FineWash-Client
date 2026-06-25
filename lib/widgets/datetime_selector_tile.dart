import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 날짜·시간 선택 타일 (아이콘 + 라벨 + 값 + chevron)
class DateTimeSelectorTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String placeholder;

  const DateTimeSelectorTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.placeholder = '선택',
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value.contains(placeholder);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
