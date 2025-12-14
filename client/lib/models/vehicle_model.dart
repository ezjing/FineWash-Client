enum VehicleSize { small, medium, large, suv }

extension VehicleSizeExtension on VehicleSize {
  String get label {
    switch (this) {
      case VehicleSize.small:
        return '소형';
      case VehicleSize.medium:
        return '중형';
      case VehicleSize.large:
        return '대형';
      case VehicleSize.suv:
        return 'SUV';
    }
  }

  String get description {
    switch (this) {
      case VehicleSize.small:
        return '경차, 소형차';
      case VehicleSize.medium:
        return '준중형, 중형';
      case VehicleSize.large:
        return '대형 세단';
      case VehicleSize.suv:
        return 'SUV, RV';
    }
  }
}

class VehicleModel {
  final String id;
  final String name;
  final String number;
  final VehicleSize size;
  final String? userId;

  VehicleModel({
    required this.id,
    required this.name,
    required this.number,
    required this.size,
    this.userId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      size: VehicleSize.values.firstWhere(
        (e) => e.name == json['size'],
        orElse: () => VehicleSize.medium,
      ),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'size': size.name,
      'userId': userId,
    };
  }

  String get displayName => '$name ($number)';
}

