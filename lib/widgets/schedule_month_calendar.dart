import 'package:flutter/material.dart';

import '../models/schedule_detail_model.dart';
import '../utils/app_colors.dart';
import '../utils/date_format_util.dart';

/// 월별 스케줄 캘린더 — StatefulWidget 부모 재빌드 시 날짜 셀만 갱신
class ScheduleMonthCalendar extends StatelessWidget {
  final DateTime selectedMonth;
  final List<ScheduleDetailModel> details;
  final ValueChanged<DateTime> onDateTap;

  const ScheduleMonthCalendar({
    super.key,
    required this.selectedMonth,
    required this.details,
    required this.onDateTap,
  });

  static const _weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;
    final today = DateTime.now();

    final detailMap = {
      for (final detail in details) detail.scheduleDate: detail,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: _weekdayLabels
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: switch (day) {
                            '일' => AppColors.error,
                            '토' => AppColors.primary,
                            _ => AppColors.textPrimary,
                          },
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: firstDayOfWeek + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstDayOfWeek) {
                  return const SizedBox.shrink();
                }

                final day = index - firstDayOfWeek + 1;
                final date = DateTime(
                  selectedMonth.year,
                  selectedMonth.month,
                  day,
                );
                final dateKey = DateFormatUtil.toDateKey(date);
                final detail = detailMap[dateKey];

                return _ScheduleDayCell(
                  day: day,
                  isToday: date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day,
                  markerColor: detail == null
                      ? null
                      : detail.isVacation
                      ? AppColors.purple
                      : AppColors.orange,
                  onTap: () => onDateTap(date),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final Color? markerColor;
  final VoidCallback onTap;

  const _ScheduleDayCell({
    required this.day,
    required this.isToday,
    required this.markerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withAlpha((0.1 * 255).round())
              : Colors.white,
          border: Border.all(
            color: isToday ? AppColors.primary : AppColors.border,
            width: isToday ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (markerColor != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
