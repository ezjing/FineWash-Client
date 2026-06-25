import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// 주소 검색 입력 타일 — 출장·제휴 예약 Step 1 공통
class LocationSearchTile extends StatelessWidget {
  final String? address;
  final String placeholder;
  final VoidCallback onTap;

  const LocationSearchTile({
    super.key,
    required this.address,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null && address!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasAddress ? address! : placeholder,
                style: TextStyle(
                  color: hasAddress
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
