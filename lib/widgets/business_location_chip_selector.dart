import 'package:flutter/material.dart';

import '../models/business_master_model.dart';
import '../utils/app_colors.dart';

/// 대시보드 사업장 칩 선택기 (전체 + 개별 사업장)
class BusinessLocationChipSelector extends StatelessWidget {
  final List<BusinessMasterModel> businesses;
  final int? selectedBusMstIdx;
  final ValueChanged<int?> onSelected;
  final bool includeAll;

  const BusinessLocationChipSelector({
    super.key,
    required this.businesses,
    required this.selectedBusMstIdx,
    required this.onSelected,
    this.includeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '사업장 선택',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (includeAll)
                _LocationChip(
                  label: '전체',
                  isSelected: selectedBusMstIdx == null,
                  onTap: () => onSelected(null),
                ),
              ...businesses.map(
                (business) => _LocationChip(
                  label: business.companyName ?? '사업장 #${business.busMstIdx}',
                  isSelected: selectedBusMstIdx == business.busMstIdx,
                  onTap: () => onSelected(business.busMstIdx),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
