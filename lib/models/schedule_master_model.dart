class ScheduleMasterModel {
  static const koreanDayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  final int schMstIdx;
  final int busMstIdx;
  final bool mondayYn;
  final bool tuesdayYn;
  final bool wednesdayYn;
  final bool thursdayYn;
  final bool fridayYn;
  final bool saturdayYn;
  final bool sundayYn;
  final String? startTime;
  final String? endTime;

  const ScheduleMasterModel({
    required this.schMstIdx,
    required this.busMstIdx,
    this.mondayYn = false,
    this.tuesdayYn = false,
    this.wednesdayYn = false,
    this.thursdayYn = false,
    this.fridayYn = false,
    this.saturdayYn = false,
    this.sundayYn = false,
    this.startTime,
    this.endTime,
  });

  static bool _parseYn(dynamic value) => value == 'Y' || value == true;

  static String _formatTime(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  factory ScheduleMasterModel.fromJson(Map<String, dynamic> json) {
    return ScheduleMasterModel(
      schMstIdx: json['schMstIdx'] ?? 0,
      busMstIdx: json['busMstIdx'] ?? 0,
      mondayYn: _parseYn(json['mondayYn']),
      tuesdayYn: _parseYn(json['tuesdayYn']),
      wednesdayYn: _parseYn(json['wednesdayYn']),
      thursdayYn: _parseYn(json['thursdayYn']),
      fridayYn: _parseYn(json['fridayYn']),
      saturdayYn: _parseYn(json['saturdayYn']),
      sundayYn: _parseYn(json['sundayYn']),
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
      'schMstIdx': schMstIdx,
      'busMstIdx': busMstIdx,
      'mondayYn': mondayYn ? 'Y' : 'N',
      'tuesdayYn': tuesdayYn ? 'Y' : 'N',
      'wednesdayYn': wednesdayYn ? 'Y' : 'N',
      'thursdayYn': thursdayYn ? 'Y' : 'N',
      'fridayYn': fridayYn ? 'Y' : 'N',
      'saturdayYn': saturdayYn ? 'Y' : 'N',
      'sundayYn': sundayYn ? 'Y' : 'N',
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  bool isWorkDay(int weekday) {
    return switch (weekday) {
      DateTime.monday => mondayYn,
      DateTime.tuesday => tuesdayYn,
      DateTime.wednesday => wednesdayYn,
      DateTime.thursday => thursdayYn,
      DateTime.friday => fridayYn,
      DateTime.saturday => saturdayYn,
      DateTime.sunday => sundayYn,
      _ => false,
    };
  }

  Map<String, bool> toWorkDaysMap() => {
    '월': mondayYn,
    '화': tuesdayYn,
    '수': wednesdayYn,
    '목': thursdayYn,
    '금': fridayYn,
    '토': saturdayYn,
    '일': sundayYn,
  };

  /// 다이얼로그 초기값용 — master 없으면 평일 근무 기본값
  static Map<String, bool> workDaysFrom(ScheduleMasterModel? master) {
    if (master == null) {
      return {
        for (final day in koreanDayLabels)
          day: day != '토' && day != '일',
      };
    }
    return master.toWorkDaysMap();
  }
}
