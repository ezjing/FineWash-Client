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
      resvIdx: json['id'] ?? json['resvIdx'] ?? json['resv_idx'] ?? 0,
      busDtlIdx: json['busDtlIdx'] ?? json['bus_dtl_idx'],
      memIdx: json['memIdx'] ?? json['mem_idx'],
      vehIdx: json['vehicleId'] ?? json['vehIdx'] ?? json['veh_idx'],
      mainOption: json['mainOption'] ?? json['main_option'],
      midOption: json['midOption'] ?? json['mid_option'],
      subOption: json['subOption'] ?? json['sub_option'],
      vehicleLocation: json['vehicleLocation'] ?? json['vehicle_location'],
      contractYn: json['contractYn'] ?? json['contract_yn'] ?? 'Y',
      date: json['date'],
      time: json['time'],
      impUid: json['impUid'] ?? json['imp_uid'],
      merchantUid: json['merchantUid'] ?? json['merchant_uid'],
      paymentAmount: json['paymentAmount'] ?? json['payment_amount'],
      createdDate: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
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
      'id': resvIdx,
      'resvIdx': resvIdx,
      'resv_idx': resvIdx,
      'busDtlIdx': busDtlIdx,
      'bus_dtl_idx': busDtlIdx,
      'memIdx': memIdx,
      'mem_idx': memIdx,
      'vehicleId': vehIdx,
      'vehIdx': vehIdx,
      'veh_idx': vehIdx,
      'mainOption': mainOption,
      'main_option': mainOption,
      'midOption': midOption,
      'mid_option': midOption,
      'subOption': subOption,
      'sub_option': subOption,
      'vehicleLocation': vehicleLocation,
      'vehicle_location': vehicleLocation,
      'contractYn': contractYn,
      'contract_yn': contractYn,
      'date': date,
      'time': time,
      'impUid': impUid,
      'imp_uid': impUid,
      'merchantUid': merchantUid,
      'merchant_uid': merchantUid,
      'paymentAmount': paymentAmount,
      'payment_amount': paymentAmount,
      'createdAt': createdDate?.toIso8601String(),
      'created_date': createdDate?.toIso8601String(),
      'createdDate': createdDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'update_date': updateDate?.toIso8601String(),
    };
  }

  bool get isConfirmed => contractYn == 'Y';
  bool get isCancelled => contractYn == 'N';
}
