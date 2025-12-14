import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<String> _cart = [];

  void _addToCart(String productId) {
    setState(() => _cart.add(productId));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('장바구니에 추가되었습니다'), duration: Duration(seconds: 1), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('쇼핑몰'), backgroundColor: Colors.white,
        actions: [Stack(children: [IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}), if (_cart.isNotEmpty) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text(_cart.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))))])],
      ),
      body: Column(
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: const BoxDecoration(gradient: AppColors.purpleGradient), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('세차 용품 특가전', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 8), Text('전 상품 무료배송', style: TextStyle(fontSize: 16, color: Colors.white70))])),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.65),
              itemCount: dummyProducts.length,
              itemBuilder: (context, index) {
                final product = dummyProducts[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Container(width: double.infinity, decoration: const BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.vertical(top: Radius.circular(16))), child: Center(child: Text(product.image, style: const TextStyle(fontSize: 48))))),
                      Expanded(flex: 4, child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)), const SizedBox(height: 4), Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), Text('${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.purple)), const SizedBox(height: 8), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _addToCart(product.id), style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, minimumSize: const Size(double.infinity, 36), padding: EdgeInsets.zero), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 16), SizedBox(width: 4), Text('장바구니', style: TextStyle(fontSize: 12))])))]))),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_cart.isNotEmpty) Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]), child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple), child: Text('장바구니 보기 (${_cart.length})'))),
        ],
      ),
    );
  }
}

