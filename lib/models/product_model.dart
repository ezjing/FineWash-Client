class ProductModel {
  final String id;
  final String name;
  final int price;
  final String image;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });
}

// 더미 상품 데이터
final List<ProductModel> dummyProducts = [
  ProductModel(
    id: '1',
    name: '프리미엄 세차 샴푸',
    price: 25000,
    image: '🧴',
    category: '세차용품',
  ),
  ProductModel(
    id: '2',
    name: '마이크로파이버 타월',
    price: 15000,
    image: '🧽',
    category: '세차용품',
  ),
  ProductModel(
    id: '3',
    name: '왁스 코팅제',
    price: 35000,
    image: '✨',
    category: '코팅제',
  ),
  ProductModel(
    id: '4',
    name: '타이어 광택제',
    price: 18000,
    image: '⚫',
    category: '타이어',
  ),
  ProductModel(
    id: '5',
    name: '실내 방향제',
    price: 12000,
    image: '🌸',
    category: '방향제',
  ),
  ProductModel(
    id: '6',
    name: '유리세정제',
    price: 16000,
    image: '💧',
    category: '세정제',
  ),
];
