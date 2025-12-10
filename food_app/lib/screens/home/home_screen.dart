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
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../support/support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  String _search = '';

  final List<String> _categories = ['All', 'Combos', 'Sliders', 'Classics'];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    // Filtering Logic
    final filteredProducts = productProvider.products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;

      final matchesSearch =
          _search.trim().isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.description.toLowerCase().contains(_search.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF2A39),
        elevation: 6,
        child: const Icon(Icons.add, size: 30),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ------------------------------- BODY --------------------------------
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Foodago',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Order your favorite food',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Cart With Badge
                  Consumer<CartProvider>(
                    builder: (context, cart, _) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                        ),

                        if (cart.itemCount > 0)
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
                                cart.itemCount.toString(),
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

                  // PROFILE → Go to ProfileScreen
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/user.png'),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------- SEARCH BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF2A39),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ---------------- CATEGORY CHIPS ----------------
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = _categories[i];
                  final active = c == _selectedCategory;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFEF2A39)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // ---------------- PRODUCT GRID ----------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _loading
                    ? const _ShimmerGrid()
                    : filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemBuilder: (ctx, idx) {
                          final product = filteredProducts[idx];
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
            ),
          ],
        ),
      ),

      // -------------------- WORKING NAV BAR ---------------------
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}
