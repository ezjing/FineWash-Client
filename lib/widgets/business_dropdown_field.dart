import 'package:flutter/material.dart';

import '../models/business_master_model.dart';

/// 사업장 선택 드롭다운 — 스케줄·예약 관리 공통
class BusinessDropdownField extends StatelessWidget {
  final List<BusinessMasterModel> businesses;
  final int? value;
  final ValueChanged<int?>? onChanged;
  final String labelText;

  const BusinessDropdownField({
    super.key,
    required this.businesses,
    required this.value,
    required this.onChanged,
    this.labelText = '사업장',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: businesses
          .map(
            (b) => DropdownMenuItem(
              value: b.busMstIdx,
              child: Text(b.companyName ?? '사업장 #${b.busMstIdx}'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
