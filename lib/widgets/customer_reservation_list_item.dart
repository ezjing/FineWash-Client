import 'package:flutter/material.dart';

import '../models/reservation_model.dart';
import '../utils/app_colors.dart';
import '../utils/reservation_cancel_util.dart';
import 'reservation_status_badge.dart';

/// 고객 마이페이지·예약 내역 공통 카드
class CustomerReservationListItem extends StatelessWidget {
  final ReservationModel reservation;
  final bool compact;

  const CustomerReservationListItem({
    super.key,
    required this.reservation,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleLines = <String>[
      if ((reservation.date ?? '').isNotEmpty ||
          (reservation.time ?? '').isNotEmpty)
        '${reservation.date ?? ''} ${reservation.time ?? ''}'.trim(),
      if (!compact) ...[
        reservation.isAffiliateReservation ? '구분: 제휴세차장' : '구분: 출장세차',
        if (!reservation.isAffiliateReservation &&
            (reservation.vehicleLocation ?? '').isNotEmpty)
          '차량 위치: ${reservation.vehicleLocation}',
      ],
    ];

    return Container(
      margin: compact ? const EdgeInsets.only(bottom: 12) : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!compact) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_car_wash_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (reservation.mainOption ?? '예약').trim().isEmpty
                                ? '예약'
                                : (reservation.mainOption ?? '예약'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ReservationStatusBadge(reservation: reservation),
                      ],
                    ),
                    if ((reservation.midOption ?? '').isNotEmpty ||
                        (reservation.subOption ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        [
                          if ((reservation.midOption ?? '').isNotEmpty)
                            reservation.midOption,
                          if ((reservation.subOption ?? '').isNotEmpty)
                            reservation.subOption,
                        ].whereType<String>().join(' · '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    ...subtitleLines.map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (reservation.isPending) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => confirmAndCancelReservation(
                  context,
                  resvIdx: reservation.resvIdx,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('예약 취소'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
