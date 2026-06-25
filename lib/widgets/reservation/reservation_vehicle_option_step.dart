import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/vehicle_service.dart';
import '../../services/wash_option_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import 'reservation_hint_banner.dart';
import 'reservation_step_config.dart';

/// 예약 Step 2 — 차량 + 중·소옵션 선택 (출장·제휴 공통)
class ReservationVehicleOptionStep extends StatelessWidget {
  final ReservationStepConfig config;
  final int? busMstIdx;
  final int? selectedVehicleId;
  final int? selectedWoptMstIdx;
  final int? selectedWoptDtlIdx;
  final int totalPrice;
  final Future<void> Function() onAddVehicle;
  final ValueChanged<int?> onVehicleSelected;
  final void Function(int woptMstIdx, String? optionName) onMidOptionSelected;
  final void Function(int woptDtlIdx, String? optionName, int price)
  onSubOptionSelected;

  const ReservationVehicleOptionStep({
    super.key,
    required this.config,
    required this.busMstIdx,
    required this.selectedVehicleId,
    required this.selectedWoptMstIdx,
    required this.selectedWoptDtlIdx,
    required this.totalPrice,
    required this.onAddVehicle,
    required this.onVehicleSelected,
    required this.onMidOptionSelected,
    required this.onSubOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleService = context.watch<VehicleService>();
    final vehicles = vehicleService.vehicles;
    final accent = config.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '차량 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (vehicles.isEmpty)
          InkWell(
            onTap: onAddVehicle,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    '차량 정보 등록하기',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedVehicleId,
                hint: const Text('차량을 선택하세요'),
                isExpanded: true,
                items: [
                  ...vehicles.map(
                    (v) => DropdownMenuItem<int>(
                      value: v.vehIdx,
                      child: Text(v.displayName),
                    ),
                  ),
                  DropdownMenuItem<int>(
                    value: -1,
                    child: Row(
                      children: [
                        Icon(Icons.add, color: accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '신규 차량 등록',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == -1) {
                    await onAddVehicle();
                  } else {
                    onVehicleSelected(value);
                  }
                },
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text(
          '중옵션 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<WashOptionService>(
          builder: (context, washOptionService, _) {
            if (busMstIdx == null) {
              return ReservationHintBanner(
                message: config.step2PrerequisiteMessage,
              );
            }
            if (washOptionService.isLoading) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(color: accent),
                ),
              );
            }
            final masters = washOptionService.masters;
            if (masters.isEmpty) {
              return ReservationHintBanner(
                message: config.step2EmptyOptionsMessage,
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: masters
                  .map(
                    (m) => InkWell(
                      onTap: () =>
                          onMidOptionSelected(m.woptMstIdx, m.optionName),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: selectedWoptMstIdx == m.woptMstIdx
                              ? accent.withAlpha((0.1 * 255).round())
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedWoptMstIdx == m.woptMstIdx
                                ? accent
                                : AppColors.border,
                            width: selectedWoptMstIdx == m.woptMstIdx ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          m.optionName ?? '-',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedWoptMstIdx == m.woptMstIdx
                                ? accent
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          '소옵션 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<WashOptionService>(
          builder: (context, washOptionService, _) {
            final master = selectedWoptMstIdx == null
                ? null
                : washOptionService.masters
                      .where((m) => m.woptMstIdx == selectedWoptMstIdx)
                      .firstOrNull;
            final details = master?.details ?? const [];

            if (selectedWoptMstIdx == null) {
              return const ReservationHintBanner(
                message: '중옵션을 먼저 선택해주세요',
              );
            }
            if (details.isEmpty) {
              return const ReservationHintBanner(message: '소옵션이 없습니다');
            }
            return Column(
              children: details
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => onSubOptionSelected(
                          d.woptDtlIdx,
                          d.optionName,
                          d.value2 ?? 0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedWoptDtlIdx == d.woptDtlIdx
                                ? accent.withAlpha((0.1 * 255).round())
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedWoptDtlIdx == d.woptDtlIdx
                                  ? accent
                                  : AppColors.border,
                              width: selectedWoptDtlIdx == d.woptDtlIdx ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d.optionName ?? '-',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: selectedWoptDtlIdx == d.woptDtlIdx
                                      ? accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                formatWonWithSuffix(d.value2 ?? 0),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: selectedWoptDtlIdx == d.woptDtlIdx
                                      ? accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        if (selectedWoptMstIdx != null && selectedWoptDtlIdx != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '총 결제 금액',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  formatWonWithSuffix(totalPrice),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
