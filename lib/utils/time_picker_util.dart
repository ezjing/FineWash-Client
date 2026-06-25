import 'package:flutter/material.dart';

/// 시간 문자열 파싱·포맷·TimePicker 호출 공통 로직
class TimePickerUtil {
  TimePickerUtil._();

  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay parseTimeString(String? time, {TimeOfDay fallback = const TimeOfDay(hour: 9, minute: 0)}) {
    if (time == null) return fallback;
    final parts = time.split(':');
    if (parts.length != 2) return fallback;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? fallback.hour,
      minute: int.tryParse(parts[1]) ?? fallback.minute,
    );
  }

  static Future<String?> pickTime(
    BuildContext context, {
    String? currentTime,
    TimeOfDay fallback = const TimeOfDay(hour: 9, minute: 0),
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: parseTimeString(currentTime, fallback: fallback),
    );
    return picked == null ? null : formatTime(picked);
  }

  static bool isEndAfterStart(String start, String end) => start.compareTo(end) < 0;
}
