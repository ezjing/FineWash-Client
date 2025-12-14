enum BookingType { mobile, partner }
enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingTypeExtension on BookingType {
  String get label {
    switch (this) {
      case BookingType.mobile:
        return '출장 세차';
      case BookingType.partner:
        return '제휴 세차장';
    }
  }
}

extension BookingStatusExtension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return '대기중';
      case BookingStatus.confirmed:
        return '확정';
      case BookingStatus.completed:
        return '완료';
      case BookingStatus.cancelled:
        return '취소';
    }
  }
}

class BookingModel {
  final String id;
  final BookingType type;
  final String vehicleId;
  final String serviceType;
  final String date;
  final String time;
  final String? address;
  final String? washLocation;
  final int price;
  final BookingStatus status;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.type,
    required this.vehicleId,
    required this.serviceType,
    required this.date,
    required this.time,
    this.address,
    this.washLocation,
    required this.price,
    required this.status,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? json['_id'] ?? '',
      type: BookingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BookingType.mobile,
      ),
      vehicleId: json['vehicleId'] ?? '',
      serviceType: json['serviceType'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      address: json['address'],
      washLocation: json['washLocation'],
      price: json['price'] ?? 0,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'date': date,
      'time': time,
      'address': address,
      'washLocation': washLocation,
      'price': price,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

