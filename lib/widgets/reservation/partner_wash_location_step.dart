import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_result.dart';
import '../../models/business_detail_model.dart';
import '../../models/business_master_model.dart';
import '../../services/business_service.dart';
import '../../utils/app_colors.dart';
import '../location_search_tile.dart';
import 'reservation_hint_banner.dart';

/// 제휴 세차장 예약 Step 1 — 위치 + 세차장 선택
class PartnerWashLocationStep extends StatelessWidget {
  final AddressResult? currentLocation;
  final int? selectedBusDtlIdx;
  final VoidCallback onSearchLocation;
  final Future<void> Function({
    required int busMstIdx,
    required int busDtlIdx,
  }) onPartnerSelected;

  const PartnerWashLocationStep({
    super.key,
    required this.currentLocation,
    required this.selectedBusDtlIdx,
    required this.onSearchLocation,
    required this.onPartnerSelected,
  });

  static BusinessDetailModel? selectableRoom(BusinessMasterModel business) {
    if (business.businessDetails.isEmpty) return null;
    final active = business.businessDetails.where((d) => d.isActive).toList();
    if (active.isNotEmpty) return active.first;
    return business.businessDetails.first;
  }

  @override
  Widget build(BuildContext context) {
    final businessService = context.watch<BusinessService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '현재 위치',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LocationSearchTile(
          address: currentLocation?.fullAddress,
          placeholder: '현재 위치를 검색하세요',
          onTap: onSearchLocation,
        ),
        const SizedBox(height: 24),
        const Text(
          '세차장 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (currentLocation == null)
          const ReservationHintBanner(
            message: '위치를 입력하면 가까운 세차장을 찾아드립니다',
          )
        else if (businessService.isNearbyLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          )
        else if (businessService.nearbyErrorMessage != null)
          ReservationHintBanner(
            icon: Icons.error_outline,
            message: '가까운 세차장 목록을 불러오지 못했습니다',
            action: OutlinedButton(
              onPressed: () async {
                final loc = currentLocation;
                if (loc == null) return;
                await businessService.searchLogic2(
                  latitude: loc.latitude,
                  longitude: loc.longitude,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('다시 시도'),
            ),
          )
        else
          Builder(
            builder: (context) {
              final allNearby = businessService.nearbyBusinesses;
              final partners =
                  allNearby.where((b) => b.businessType == 'PARTNER').toList();

              if (partners.isEmpty) {
                return ReservationHintBanner(
                  message: allNearby.isEmpty
                      ? '주변 제휴 세차장이 없습니다'
                      : '조회된 사업장(${allNearby.length}개) 중 제휴(PARTNER) 세차장이 없습니다',
                );
              }

              return Column(
                children: partners.asMap().entries.map((entry) {
                  final index = entry.key;
                  final business = entry.value;
                  final isLast = index == partners.length - 1;
                  final room = selectableRoom(business);
                  final busDtlIdx = room?.busDtlIdx;
                  final isSelectable = busDtlIdx != null;
                  final isSelected =
                      isSelectable && selectedBusDtlIdx == busDtlIdx;
                  final distanceText = business.distanceKm != null
                      ? '${business.distanceKm!.toStringAsFixed(1)}km'
                      : '-';

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: InkWell(
                      onTap: isSelectable
                          ? () => onPartnerSelected(
                              busMstIdx: business.busMstIdx,
                              busDtlIdx: busDtlIdx,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary.withAlpha(
                                  (0.1 * 255).round(),
                                )
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.companyName ?? '세차장',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    business.address ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (room?.roomName != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.meeting_room_outlined,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      room!.roomName!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!isSelectable)
                                  const Text(
                                    '예약 가능한 룸 정보가 없습니다',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                Text(
                                  distanceText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
