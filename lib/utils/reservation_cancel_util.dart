import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reservation_service.dart';
import '../utils/app_colors.dart';
import 'app_snackbar.dart';

/// 대기 중 예약 취소 확인 다이얼로그 + API 호출
Future<bool> confirmAndCancelReservation(
  BuildContext context, {
  required int resvIdx,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('예약 취소'),
      content: const Text('이 예약을 취소하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('닫기'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('취소하기'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return false;

  final ok = await context.read<ReservationService>().cancelReservation(
    resvIdx,
  );

  if (!context.mounted) return ok;

  showAppSnackBar(
    context,
    message: ok ? '예약이 취소되었습니다.' : '예약 취소에 실패했습니다.',
    type: ok ? AppSnackBarType.success : AppSnackBarType.error,
  );

  return ok;
}
