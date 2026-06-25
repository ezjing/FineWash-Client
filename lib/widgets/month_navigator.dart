import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 월 이동 헤더 — 스케줄 관리·대시보드 공통
class MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onTitleTap;

  /// `header`: 스케줄 관리 스타일 (하단 보더)
  /// `card`: 대시보드 스타일 (둥근 테두리, 탭 가능)
  final MonthNavigatorVariant variant;

  const MonthNavigator({
    super.key,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
    this.onTitleTap,
    this.variant = MonthNavigatorVariant.header,
  });

  @override
  Widget build(BuildContext context) {
    final title = '${selectedMonth.year}년 ${selectedMonth.month}월';
    final isCard = variant == MonthNavigatorVariant.card;

    final titleWidget = Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isCard ? 16 : 18,
        fontWeight: isCard ? FontWeight.w600 : FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );

    return Container(
      padding: EdgeInsets.all(isCard ? 0 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCard ? BorderRadius.circular(12) : null,
        border: isCard
            ? Border.all(color: AppColors.border)
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: isCard
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 12)
            : EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
              color: AppColors.textPrimary,
            ),
            Expanded(
              child: onTitleTap != null
                  ? InkWell(
                      onTap: onTitleTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: titleWidget,
                      ),
                    )
                  : titleWidget,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

enum MonthNavigatorVariant { header, card }
