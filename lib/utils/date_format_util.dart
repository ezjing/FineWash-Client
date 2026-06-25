/// API·캘린더·예약에서 공통으로 쓰는 날짜 문자열 포맷
class DateFormatUtil {
  DateFormatUtil._();

  /// `yyyy-MM-dd` (API 전송·키 조회용)
  static String toDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// `2025년 6월 24일` (화면 표시용)
  static String toKoreanDate(DateTime date) =>
      '${date.year}년 ${date.month}월 ${date.day}일';
}
