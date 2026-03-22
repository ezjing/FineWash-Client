import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// 옵션 관리 탭 등과 동일한 빈 목록 안내 (아이콘 + 제목 + 부제)
class EmptyStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry? padding;

  const EmptyStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final effectivePadding =
        padding ?? EdgeInsets.fromLTRB(24, 0, 24, bottom + 24);
    return Center(
      child: Padding(
        padding: effectivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
