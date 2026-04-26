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

