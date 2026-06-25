import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// 출장·제휴 예약 Step UI 공통 설정
class ReservationStepConfig {
  final Color accentColor;
  final String step2PrerequisiteMessage;
  final String step2EmptyOptionsMessage;

  const ReservationStepConfig({
    required this.accentColor,
    required this.step2PrerequisiteMessage,
    required this.step2EmptyOptionsMessage,
  });

  static const mobile = ReservationStepConfig(
    accentColor: AppColors.primary,
    step2PrerequisiteMessage: '먼저 출장세차 업자를 선택해주세요',
    step2EmptyOptionsMessage: '해당 업자에 등록된 세차 옵션이 없습니다',
  );

  static const partner = ReservationStepConfig(
    accentColor: AppColors.secondary,
    step2PrerequisiteMessage: '먼저 세차장을 선택해주세요',
    step2EmptyOptionsMessage: '해당 세차장에 등록된 세차 옵션이 없습니다',
  );
}
