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
  String _selectedCategory = 'All';
  String _searchQuery = '';
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _onBottomTap(int index) {
    setState(() => _bottomIndex = index);

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

    // 🔹 Build category list dynamically
    final categories = [
      'All',
      ...{for (var p in productProvider.products) p.category},
    ];

    // 🔹 Apply category + search filter
    final products = productProvider.products.where((p) {
      final matchCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchCategory && matchSearch;
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
            // ================= HEADER =================
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

                  // ================= CART =================
                  Consumer<CartProvider>(
                    builder: (_, cart, __) => Stack(
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
                        if (cart.items.isNotEmpty)
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
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ================= SEARCH BAR =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Search food...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ================= CATEGORIES =================
            SizedBox(
              height: 45,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final selected = cat == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: const Color(0xFFEF2A39),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ================= PRODUCT GRID =================
            Expanded(
              child: productProvider.isLoading
                  ? const _ShimmerGrid()
                  : products.isEmpty
                  ? const Center(child: Text("No products found"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemBuilder: (_, i) {
                        final product = products[i];
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

// ================= SHIMMER =================
class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
