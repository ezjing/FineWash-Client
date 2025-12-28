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
      vehIdx: json['id'] ?? json['vehIdx'] ?? json['veh_idx'] ?? 0,
      memIdx: json['memIdx'] ?? json['mem_idx'],
      vehicleType: json['vehicleType'] ?? json['vehicle_type'],
      model: json['model'],
      vehicleNumber: json['vehicleNumber'] ?? json['vehicle_number'],
      color: json['color'],
      year: json['year'],
      remark: json['remark'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : json['created_date'] != null
              ? DateTime.parse(json['created_date'])
              : null,
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : json['update_date'] != null
              ? DateTime.parse(json['update_date'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': vehIdx,
      'vehIdx': vehIdx,
      'veh_idx': vehIdx,
      'memIdx': memIdx,
      'mem_idx': memIdx,
      'vehicleType': vehicleType,
      'vehicle_type': vehicleType,
      'model': model,
      'vehicleNumber': vehicleNumber,
      'vehicle_number': vehicleNumber,
      'color': color,
      'year': year,
      'remark': remark,
      'createdDate': createdDate?.toIso8601String(),
      'created_date': createdDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'update_date': updateDate?.toIso8601String(),
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

