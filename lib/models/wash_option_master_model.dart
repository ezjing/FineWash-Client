import 'wash_option_detail_model.dart';

/// WashOptionMaster — 서버 `wash_option_masters` + nested `details`
class WashOptionMasterModel {
  final int woptMstIdx;
  final int busMstIdx;
  final String? optionName;
  final String? vehicleType;
  final int seq;
  final int? value1;
  final int? value2;
  final List<WashOptionDetailModel> details;

  WashOptionMasterModel({
    required this.woptMstIdx,
    required this.busMstIdx,
    this.optionName,
    this.vehicleType,
    this.seq = 0,
    this.value1,
    this.value2,
    List<WashOptionDetailModel>? details,
  }) : details = details ?? [];

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  factory WashOptionMasterModel.fromJson(Map<String, dynamic> json) {
    final dtl = json['details'] as List?;
    return WashOptionMasterModel(
      woptMstIdx: _int(json['woptMstIdx']) ?? 0,
      busMstIdx: _int(json['busMstIdx']) ?? 0,
      optionName: json['optionName'] as String?,
      vehicleType: json['vehicleType'] as String?,
      seq: _int(json['seq']) ?? 0,
      value1: _int(json['value1']),
      value2: _int(json['value2']),
      details:
          dtl
              ?.map(
                (e) =>
                    WashOptionDetailModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
