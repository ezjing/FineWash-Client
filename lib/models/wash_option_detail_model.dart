/// WashOptionDetail — 서버 `wash_option_details` / API camelCase
class WashOptionDetailModel {
  final int woptDtlIdx;
  final int woptMstIdx;
  final String? optionName;
  final String? vehicleType;
  final int seq;
  final int? value1;
  final int? value2;

  WashOptionDetailModel({
    required this.woptDtlIdx,
    required this.woptMstIdx,
    this.optionName,
    this.vehicleType,
    this.seq = 0,
    this.value1,
    this.value2,
  });

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  factory WashOptionDetailModel.fromJson(Map<String, dynamic> json) {
    return WashOptionDetailModel(
      woptDtlIdx: _int(json['woptDtlIdx']) ?? 0,
      woptMstIdx: _int(json['woptMstIdx']) ?? 0,
      optionName: json['optionName'] as String?,
      vehicleType: json['vehicleType'] as String?,
      seq: _int(json['seq']) ?? 0,
      value1: _int(json['value1']),
      value2: _int(json['value2']),
    );
  }

  Map<String, dynamic> toJson() => {
    'woptDtlIdx': woptDtlIdx,
    'woptMstIdx': woptMstIdx,
    'optionName': optionName,
    'vehicleType': vehicleType,
    'seq': seq,
    'value1': value1,
    'value2': value2,
  };
}
