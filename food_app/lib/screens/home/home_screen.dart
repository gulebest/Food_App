// lib/screens/home/home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/product_card.dart';
import '../product/product_details.dart';
import '../cart/cart_screen.dart';

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
    // small shimmer delay to simulate load
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context).products;
    final cart = Provider.of<CartProvider>(context);
    final favProvider = Provider.of<FavoriteProvider>(context);

    // Filtering: (we don't have categories on Product model) - keep "All" behavior.
    final visible = _search.trim().isEmpty
        ? products
        : products
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_search.toLowerCase()) ||
                    p.description.toLowerCase().contains(_search.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      // center docked FAB:
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEF2A39),
        elevation: 6,
        child: const Icon(Icons.add, size: 30),
        onPressed: () {
          // placeholder action — you can route to add item / new order screen
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add action tapped')));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SafeArea(
        child: Column(
          children: [
            // top area: padding + header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Foodago',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Cart icon with badge
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

                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                ],
              ),
            ),

            // search + filter row
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

            // categories chips
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

            // content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _loading
                    ? const _ShimmerGrid()
                    : visible.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : GridView.builder(
                        itemCount: visible.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemBuilder: (ctx, idx) {
                          final product = visible[idx];

                          // show product card (your ProductCard handles rating + favorite)
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

      // custom bottom nav (center FAB sits above this)
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navBtn(icon: Icons.home_rounded, index: 0),
          _navBtn(icon: Icons.person_outline, index: 1),
          // center gap for FAB:
          const SizedBox(width: 48),
          _navBtn(icon: Icons.message_outlined, index: 2),
          _navBtn(icon: Icons.favorite_rounded, index: 3),
        ],
      ),
    );
  }

  Widget _navBtn({required IconData icon, required int index}) {
    final bool active = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        // you can add navigation to other pages here
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 14 : 8,
          vertical: active ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: active ? 30 : 26,
          color: active ? Colors.black : Colors.grey,
        ),
      ),
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
