class ServiceTypeModel {
  final String id;
  final String name;
  final int price;
  final String description;

  ServiceTypeModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}

// 출장 세차 서비스 타입
final List<ServiceTypeModel> mobileWashServices = [
  ServiceTypeModel(id: 'basic', name: '기본 세차', price: 30000, description: '외부 세차 + 실내 청소'),
  ServiceTypeModel(id: 'premium', name: '프리미엄 세차', price: 50000, description: '기본 세차 + 왁스 + 엔진룸'),
  ServiceTypeModel(id: 'full', name: '풀 패키지', price: 80000, description: '프리미엄 + 코팅 + 실내 소독'),
];

// 제휴 세차장 서비스 타입
final List<ServiceTypeModel> partnerWashServices = [
  ServiceTypeModel(id: 'basic', name: '기본 세차', price: 25000, description: '외부 세차 + 실내 청소'),
  ServiceTypeModel(id: 'premium', name: '프리미엄 세차', price: 40000, description: '기본 세차 + 왁스 + 엔진룸'),
  ServiceTypeModel(id: 'full', name: '풀 패키지', price: 65000, description: '프리미엄 + 코팅 + 실내 소독'),
];

