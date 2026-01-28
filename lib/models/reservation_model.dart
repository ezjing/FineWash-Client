class ReservationModel {
  final int resvIdx;
  final int? busDtlIdx; // 사업장 DTL 인덱스
  final int? memIdx; // 회원 인덱스
  final int? vehIdx; // 차량정보 인덱스
  final String? mainOption; // 예약 대옵션 (출장, 방문)
  final String? midOption; // 예약 중옵션 (내/외부)
  final String? subOption; // 예약 소옵션 (스팀, 내부먼지제거 등)
  final String? vehicleLocation; // 자동차 위치
  final String contractYn; // 계약체결YN (Y: 승낙, N: 취소)
  final String? date; // 예약일자
  final String? time; // 예약시간
  final String? impUid; // 포트원 결제 고유번호
  final String? merchantUid; // 주문 고유번호
  final int? paymentAmount; // 결제 금액
  final DateTime? createdDate;
  final DateTime? updateDate;

  ReservationModel({
    required this.resvIdx,
    this.busDtlIdx,
    this.memIdx,
    this.vehIdx,
    this.mainOption,
    this.midOption,
    this.subOption,
    this.vehicleLocation,
    this.contractYn = 'Y',
    this.date,
    this.time,
    this.impUid,
    this.merchantUid,
    this.paymentAmount,
    this.createdDate,
    this.updateDate,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      resvIdx: json['resvIdx'] ?? 0,
      busDtlIdx: json['busDtlIdx'],
      memIdx: json['memIdx'],
      vehIdx: json['vehIdx'],
      mainOption: json['mainOption'],
      midOption: json['midOption'],
      subOption: json['subOption'],
      vehicleLocation: json['vehicleLocation'],
      contractYn: json['contractYn'] ?? 'Y',
      date: json['date'],
      time: json['time'],
      impUid: json['impUid'],
      merchantUid: json['merchantUid'],
      paymentAmount: json['paymentAmount'],
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
      'resvIdx': resvIdx,
      'busDtlIdx': busDtlIdx,
      'memIdx': memIdx,
      'vehIdx': vehIdx,
      'mainOption': mainOption,
      'midOption': midOption,
      'subOption': subOption,
      'vehicleLocation': vehicleLocation,
      'contractYn': contractYn,
      'date': date,
      'time': time,
      'impUid': impUid,
      'merchantUid': merchantUid,
      'paymentAmount': paymentAmount,
      'createdDate': createdDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
    };
  }

  bool get isConfirmed => contractYn == 'Y';
  bool get isCancelled => contractYn == 'N';
}
