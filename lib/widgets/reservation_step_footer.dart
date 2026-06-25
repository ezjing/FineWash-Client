import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 다단계 예약 화면 하단 이전/다음 버튼 영역
class ReservationStepFooter extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canProceed;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Color primaryColor;

  const ReservationStepFooter({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canProceed,
    required this.onPrevious,
    required this.onNext,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottomPadding + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (currentStep > 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('이전'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed && currentStep < totalSteps ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                currentStep < totalSteps ? '다음' : '완료',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
