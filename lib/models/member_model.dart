class MemberModel {
  final int memIdx;
  final int? busMstIdx;
  final String? userId;
  final String? name;
  final String? fcmToken;
  final String? address;
  final String? phone;
  final String? gender; // M: 남성, F: 여성, N: 미선택
  final String? email;
  final String? socialType;
  final String? socialId;
  final String? memberType; // C: 고객, B: 사업자
  final DateTime? createdDate;
  final DateTime? updateDate;

  MemberModel({
    required this.memIdx,
    this.busMstIdx,
    this.userId,
    this.name,
    this.fcmToken,
    this.address,
    this.phone,
    this.gender,
    this.email,
    this.socialType,
    this.socialId,
    this.memberType,
    this.createdDate,
    this.updateDate,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      memIdx: json['memIdx'] ?? 0,
      busMstIdx: json['busMstIdx'],
      userId: json['userId'],
      name: json['name'],
      fcmToken: json['fcmToken'],
      address: json['address'],
      phone: json['phone'],
      gender: json['gender'],
      email: json['email'],
      socialType: json['socialType'],
      socialId: json['socialId'],
      memberType: json['memberType'] ?? 'C',
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
      'memIdx': memIdx,
      'busMstIdx': busMstIdx,
      'userId': userId,
      'name': name,
      'fcmToken': fcmToken,
      'address': address,
      'phone': phone,
      'gender': gender,
      'email': email,
      'socialType': socialType,
      'socialId': socialId,
      'memberType': memberType,
      'createdDate': createdDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
    };
  }

  MemberModel copyWith({
    int? memIdx,
    int? busMstIdx,
    String? userId,
    String? name,
    String? fcmToken,
    String? address,
    String? phone,
    String? gender,
    String? email,
    String? socialType,
    String? socialId,
    String? memberType,
    DateTime? createdDate,
    DateTime? updateDate,
  }) {
    return MemberModel(
      memIdx: memIdx ?? this.memIdx,
      busMstIdx: busMstIdx ?? this.busMstIdx,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      fcmToken: fcmToken ?? this.fcmToken,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      socialType: socialType ?? this.socialType,
      socialId: socialId ?? this.socialId,
      memberType: memberType ?? this.memberType,
      createdDate: createdDate ?? this.createdDate,
      updateDate: updateDate ?? this.updateDate,
    );
  }
}
