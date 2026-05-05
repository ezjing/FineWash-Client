import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ReservationStepIndicator extends StatelessWidget {
  const ReservationStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitles,
    required this.activeColor,
  }) : assert(currentStep >= 1),
       assert(stepTitles.length >= 2);

  final int currentStep;
  final List<String> stepTitles;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final totalSteps = stepTitles.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final step = index + 1;
          final isActive = step == currentStep;
          final isCompleted = step < currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive || isCompleted
                              ? activeColor
                              : AppColors.border,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '$step',
                                  style: TextStyle(
                                    color: isActive || isCompleted
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive || isCompleted
                              ? activeColor
                              : AppColors.textSecondary,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (step < totalSteps)
                  Container(
                    width: 20,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isCompleted ? activeColor : AppColors.border,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
