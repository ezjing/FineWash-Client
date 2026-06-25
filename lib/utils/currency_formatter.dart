/// 통화(원) 표기용 포맷터
///
/// - `1234567` -> `1,234,567`
/// - UI 표기에서만 사용 (서버 전송 값 변환 금지)
String formatWon(num amount) {
  final value = amount.round();
  final s = value.toString();
  return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

String formatWonWithSuffix(num amount, {String suffix = '원'}) {
  return '${formatWon(amount)}$suffix';
}

/// 대시보드·통계 카드용 천 단위 구분 숫자
String formatNumber(num value) {
  return value.round().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}

/// 만원 단위 축약 매출 표기
String formatCompactRevenue(int amount) {
  if (amount >= 10000) {
    final man = amount / 10000;
    return man >= 10
        ? formatNumber(man.round())
        : man.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  }
  return formatNumber(amount);
}

String revenueUnit(int amount) => amount >= 10000 ? '만원' : '원';

