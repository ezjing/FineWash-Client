import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// 아이콘(16) + 본문 한 줄 — 카드 본문 정보 행 공통
class SummaryIconInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool expandText;

  const SummaryIconInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.expandText = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
    );
    final textWidget = Text(text, style: style);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        if (expandText) Expanded(child: textWidget) else textWidget,
      ],
    );
  }
}
