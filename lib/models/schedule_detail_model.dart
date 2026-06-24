class ScheduleDetailModel {
  final int schDtlIdx;
  final int schMstIdx;
  final String scheduleDate;
  final bool holidayYn;
  final String? startTime;
  final String? endTime;

  const ScheduleDetailModel({
    required this.schDtlIdx,
    required this.schMstIdx,
    required this.scheduleDate,
    this.holidayYn = false,
    this.startTime,
    this.endTime,
  });

  bool get isVacation => holidayYn;
  bool get isOvertime => !holidayYn;

  static bool _parseYn(dynamic value) => value == 'Y' || value == true;

  static String _formatTime(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  factory ScheduleDetailModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDetailModel(
      schDtlIdx: json['schDtlIdx'] ?? 0,
      schMstIdx: json['schMstIdx'] ?? 0,
      scheduleDate: json['scheduleDate']?.toString() ?? '',
      holidayYn: _parseYn(json['holidayYn']),
      startTime: _formatTime(json['startTime']).isEmpty
          ? null
          : _formatTime(json['startTime']),
      endTime: _formatTime(json['endTime']).isEmpty
          ? null
          : _formatTime(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schDtlIdx': schDtlIdx,
      'schMstIdx': schMstIdx,
      'scheduleDate': scheduleDate,
      'holidayYn': holidayYn ? 'Y' : 'N',
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
