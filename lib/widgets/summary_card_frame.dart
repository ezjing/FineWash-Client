import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// 사업장 / 룸 / 세차 옵션 카드 공통 외곽 (테두리·모서리·여백)
class SummaryCardFrame extends StatelessWidget {
  final Widget child;

  const SummaryCardFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: child,
    );
  }
}
