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
    this.createdDate,
    this.updateDate,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      memIdx: json['id'] ?? json['memIdx'] ?? json['mem_idx'] ?? 0,
      busMstIdx: json['busMstIdx'] ?? json['bus_mst_idx'],
      userId: json['userId'] ?? json['user_id'],
      name: json['name'],
      fcmToken: json['fcmToken'] ?? json['fcm_token'],
      address: json['address'],
      phone: json['phone'],
      gender: json['gender'],
      email: json['email'],
      socialType: json['socialType'] ?? json['social_type'],
      socialId: json['socialId'] ?? json['social_id'],
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
      'id': memIdx,
      'memIdx': memIdx,
      'mem_idx': memIdx,
      'busMstIdx': busMstIdx,
      'bus_mst_idx': busMstIdx,
      'userId': userId,
      'user_id': userId,
      'name': name,
      'fcmToken': fcmToken,
      'fcm_token': fcmToken,
      'address': address,
      'phone': phone,
      'gender': gender,
      'email': email,
      'socialType': socialType,
      'social_type': socialType,
      'socialId' : socialId,
      'social_id' : socialId,    
      'createdDate': createdDate?.toIso8601String(),
      'created_date': createdDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'update_date': updateDate?.toIso8601String(),
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
      createdDate: createdDate ?? this.createdDate,
      updateDate: updateDate ?? this.updateDate,
    );
  }
}
