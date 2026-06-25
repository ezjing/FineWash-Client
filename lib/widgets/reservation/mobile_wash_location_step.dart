import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_result.dart';
import '../../services/business_service.dart';
import '../../utils/app_colors.dart';
import '../location_search_tile.dart';
import 'reservation_hint_banner.dart';

/// 출장 세차 예약 Step 1 — 위치 + 업자 선택
class MobileWashLocationStep extends StatelessWidget {
  final AddressResult? currentLocation;
  final TextEditingController detailAddressController;
  final int? selectedBusMstIdx;
  final VoidCallback onSearchLocation;
  final Future<void> Function(int busMstIdx) onProviderSelected;

  const MobileWashLocationStep({
    super.key,
    required this.currentLocation,
    required this.detailAddressController,
    required this.selectedBusMstIdx,
    required this.onSearchLocation,
    required this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final businessService = context.watch<BusinessService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세차 위치',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LocationSearchTile(
          address: currentLocation?.fullAddress,
          placeholder: '세차 위치를 검색하세요',
          onTap: onSearchLocation,
        ),
        if (currentLocation != null) ...[
          const SizedBox(height: 8),
          Text(
            '우편번호: ${currentLocation!.zonecode}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: detailAddressController,
            decoration: const InputDecoration(
              hintText: '상세 주소를 입력하세요 (동/호수 등)',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          '출장세차 업자 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (currentLocation == null)
          const ReservationHintBanner(
            message: '위치를 입력하면 가까운 출장세차 업자를 찾아드립니다',
          )
        else if (businessService.isNearbyLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (businessService.nearbyErrorMessage != null)
          ReservationHintBanner(
            icon: Icons.error_outline,
            message: '가까운 출장세차 업자 목록을 불러오지 못했습니다',
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
              final providers =
                  allNearby.where((b) => b.businessType == 'OUT').toList();

              if (providers.isEmpty) {
                return ReservationHintBanner(
                  message: allNearby.isEmpty
                      ? '주변 출장세차 업자가 없습니다'
                      : '조회된 사업장(${allNearby.length}개) 중 출장세차(OUT) 업자가 없습니다',
                );
              }

              return Column(
                children: providers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final isLast = index == providers.length - 1;
                  final isSelected = selectedBusMstIdx == p.busMstIdx;
                  final distanceText = p.distanceKm != null
                      ? '${p.distanceKm!.toStringAsFixed(1)}km'
                      : '-';

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: InkWell(
                      onTap: () => onProviderSelected(p.busMstIdx),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(
                                  (0.1 * 255).round(),
                                )
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.companyName ?? '출장세차 업자',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
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
                                    p.address ?? '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                distanceText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
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
