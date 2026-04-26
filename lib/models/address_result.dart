/// 주소 검색 결과 모델
class AddressResult {
  final String address; // 기본 주소 (도로명 주소)
  final String jibunAddress; // 지번 주소
  final String zonecode; // 우편번호
  final String buildingName; // 건물명
  final String sido; // 시/도
  final String sigungu; // 시/군/구
  final String bname; // 법정동/법정리
  final String roadAddress; // 전체 도로명 주소
  final double latitude; // 위도
  final double longitude; // 경도

  AddressResult({
    required this.address,
    required this.jibunAddress,
    required this.zonecode,
    required this.buildingName,
    required this.sido,
    required this.sigungu,
    required this.bname,
    required this.roadAddress,
    required this.latitude,
    required this.longitude,
  });

  factory AddressResult.fromJson(Map<String, dynamic> json) {
    return AddressResult(
      address: json['address'] ?? '',
      jibunAddress: json['jibunAddress'] ?? '',
      zonecode: json['zonecode'] ?? '',
      buildingName: json['buildingName'] ?? '',
      sido: json['sido'] ?? '',
      sigungu: json['sigungu'] ?? '',
      bname: json['bname'] ?? '',
      roadAddress: json['roadAddress'] ?? '',
      latitude: _toDouble(json['latitude']) ?? 0.0,
      longitude: _toDouble(json['longitude']) ?? 0.0,
    );
  }

  AddressResult copyWith({
    double? latitude,
    double? longitude,
  }) {
    return AddressResult(
      address: address,
      jibunAddress: jibunAddress,
      zonecode: zonecode,
      buildingName: buildingName,
      sido: sido,
      sigungu: sigungu,
      bname: bname,
      roadAddress: roadAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  /// 전체 주소 문자열 반환
  String get fullAddress {
    final buffer = StringBuffer();
    buffer.write(roadAddress.isNotEmpty ? roadAddress : address);
    if (buildingName.isNotEmpty) {
      buffer.write(' ($buildingName)');
    }
    return buffer.toString();
  }

  /// 우편번호 포함 주소
  String get addressWithZonecode {
    return '[$zonecode] $fullAddress';
  }
}

