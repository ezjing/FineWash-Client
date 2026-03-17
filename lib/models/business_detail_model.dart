/// 서버 BusinessDetail 테이블 구조와 필드명 통일
class BusinessDetailModel {
  final int busDtlIdx;
  final int? busMstIdx;
  final String? roomName;
  final String? activeYn;
  final String? startDate;
  final String? endDate;

  BusinessDetailModel({
    required this.busDtlIdx,
    this.busMstIdx,
    this.roomName,
    this.activeYn,
    this.startDate,
    this.endDate,
  });

  factory BusinessDetailModel.fromJson(Map<String, dynamic> json) {
    return BusinessDetailModel(
      busDtlIdx: json['busDtlIdx'] ?? json['id'] ?? 0,
      busMstIdx: json['busMstIdx'],
      roomName: json['roomName'],
      activeYn: json['activeYn'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busDtlIdx': busDtlIdx,
      'busMstIdx': busMstIdx,
      'roomName': roomName,
      'activeYn': activeYn,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  bool get isActive => activeYn == 'Y';
}
