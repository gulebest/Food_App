// lib/screens/home/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

import '../../widgets/product_card.dart';
import '../../widgets/bottom_nav.dart';

import '../product/product_details.dart';
import '../profile/profile_screen.dart';
import '../cart/cart_screen.dart';
import '../support/support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _selectedCategory = 'All';
  String _search = '';
  int _bottomIndex = 0;

  final List<String> _categories = ['All', 'Combos', 'Sliders', 'Classics'];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  void _onBottomTap(int index) {
    setState(() => _bottomIndex = index);

    if (!mounted) return;

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupportScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    final filteredProducts = productProvider.products.where((p) {
      final categoryMatch =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final searchMatch =
          _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF2A39),
        child: const Icon(Icons.add, size: 30),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Foodago",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Order your favorite food",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Consumer<CartProvider>(
                    builder: (_, cart, __) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                        if (cart.items.length > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF2A39),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cart.items.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const _ShimmerGrid()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemBuilder: (_, i) {
                        final product = filteredProducts[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetails(productId: product.id),
                              ),
                            );
                          },
                          child: ProductCard(product: product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _bottomIndex,
        onTap: _onBottomTap,
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
