import 'package:flutter/material.dart';

import '../models/reservation_model.dart';
import '../utils/app_colors.dart';

/// 고객·사업자 예약 상태 뱃지 (contractYn: null=대기, Y=승인, N=거절)
class ReservationStatusBadge extends StatelessWidget {
  final ReservationModel reservation;

  const ReservationStatusBadge({super.key, required this.reservation});

  Color get _color {
    if (reservation.isConfirmed) return AppColors.success;
    if (reservation.isRejected) return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        reservation.statusLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
