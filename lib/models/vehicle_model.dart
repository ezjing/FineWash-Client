class VehicleModel {
  final int vehIdx;
  final int? memIdx; // 회원 인덱스
  final String? vehicleType; // 차종 (준중형 등)
  final String? model; // 모델 (그렌저 등)
  final String? vehicleNumber; // 차량번호
  final String? color; // 색상
  final int? year; // 연식
  final String? remark; // 비고
  final DateTime? createdDate;
  final DateTime? updateDate;

  VehicleModel({
    required this.vehIdx,
    this.memIdx,
    this.vehicleType,
    this.model,
    this.vehicleNumber,
    this.color,
    this.year,
    this.remark,
    this.createdDate,
    this.updateDate,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehIdx: json['vehIdx'] ?? 0,
      memIdx: json['memIdx'],
      vehicleType: json['vehicleType'],
      model: json['model'],
      vehicleNumber: json['vehicleNumber'],
      color: json['color'],
      year: json['year'],
      remark: json['remark'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehIdx': vehIdx,
      'memIdx': memIdx,
      'vehicleType': vehicleType,
      'model': model,
      'vehicleNumber': vehicleNumber,
      'color': color,
      'year': year,
      'remark': remark,
      'createdDate': createdDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
    };
  }

  String get displayName {
    if (model != null && vehicleNumber != null) {
      return '$model ($vehicleNumber)';
    } else if (model != null) {
      return model!;
    } else if (vehicleNumber != null) {
      return vehicleNumber!;
    }
    return '차량 정보 없음';
  }
}
