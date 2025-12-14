class WashLocationModel {
  final String id;
  final String name;
  final String address;
  final String distance;
  final double rating;
  final int reviewCount;

  WashLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.reviewCount,
  });
}

// 더미 데이터
final List<WashLocationModel> dummyWashLocations = [
  WashLocationModel(id: '1', name: '클린세차장 강남점', address: '서울 강남구 테헤란로 123', distance: '1.2km', rating: 4.8, reviewCount: 245),
  WashLocationModel(id: '2', name: '프리미엄세차 역삼점', address: '서울 강남구 역삼동 456', distance: '2.5km', rating: 4.6, reviewCount: 189),
  WashLocationModel(id: '3', name: '스피드세차 선릉점', address: '서울 강남구 선릉로 789', distance: '3.1km', rating: 4.7, reviewCount: 312),
];

