import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 대시보드 간단 막대 차트
class SimpleBarChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels;

  const SimpleBarChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '예약 데이터가 없습니다',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b).toDouble();
    final safeMax = maxValue == 0 ? 1.0 : maxValue;

    return SizedBox(
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const xAxisHeight = 28.0;
          const countLabelHeight = 14.0;
          const gap = 4.0;
          final maxBarHeight =
              constraints.maxHeight - xAxisHeight - countLabelHeight - gap;

          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight - xAxisHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (index) {
                    final barHeight = (data[index] / safeMax) * maxBarHeight;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (data[index] > 0)
                              Text(
                                '${data[index]}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            const SizedBox(height: gap),
                            Container(
                              width: double.infinity,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(data.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        index < labels.length ? labels[index] : '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
