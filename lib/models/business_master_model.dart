import 'business_detail_model.dart';

/// 서버 BusinessMaster 테이블 구조와 필드명 통일
class BusinessMasterModel {
  final int busMstIdx;
  final int? memIdx;
  final String? businessNumber;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? address;
  final String? addressDetail;
  final double? latitude;
  final double? longitude;
  final double? distanceKm; // 주소 기반 거리순 조회 시 포함될 수 있음
  final String? businessType;
  final String? depositYn;
  final int? depositAmount;
  final String? remark;
  final List<BusinessDetailModel> businessDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessMasterModel({
    required this.busMstIdx,
    this.memIdx,
    this.businessNumber,
    this.companyName,
    this.phone,
    this.email,
    this.address,
    this.addressDetail,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.businessType,
    this.depositYn,
    this.depositAmount,
    this.remark,
    List<BusinessDetailModel>? businessDetails,
    this.createdAt,
    this.updatedAt,
  }) : businessDetails = businessDetails ?? [];

  /// 목록/상세 API 공통: id 또는 busMstIdx
  int get id => busMstIdx;

  factory BusinessMasterModel.fromJson(Map<String, dynamic> json) {
    return BusinessMasterModel(
      busMstIdx: json['busMstIdx'] ?? json['id'] ?? 0,
      memIdx: json['memIdx'],
      businessNumber: json['businessNumber'],
      companyName: json['companyName'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      addressDetail: json['addressDetail'],
      latitude: _double(json['latitude'] ?? json['lat']),
      longitude: _double(json['longitude'] ?? json['lng']),
      distanceKm: _double(json['distanceKm'] ?? json['distance_km']),
      businessType: json['businessType'],
      depositYn: json['depositYn'],
      depositAmount: json['depositAmount'],
      remark: json['remark'],
      businessDetails:
          (json['businessDetails'] as List?)
              ?.map(
                (e) => BusinessDetailModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  Map<String, dynamic> toJson() {
    return {
      'busMstIdx': busMstIdx,
      'memIdx': memIdx,
      'businessNumber': businessNumber,
      'companyName': companyName,
      'phone': phone,
      'email': email,
      'address': address,
      'addressDetail': addressDetail,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
      'businessType': businessType,
      'depositYn': depositYn,
      'depositAmount': depositAmount,
      'remark': remark,
      'businessDetails': businessDetails.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
