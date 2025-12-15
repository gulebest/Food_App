import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../address/address_selection_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Cart",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: cartItems.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final item = cartItems[i];

                return Dismissible(
                  key: ValueKey(item.productId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => cart.removeItem(item.productId),

                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // ================= IMAGE =================
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            item.image,
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 75,
                              height: 75,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.fastfood,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ================= INFO =================
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "\$${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEF2A39),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ================= QTY =================
                        Row(
                          children: [
                            _qtyBtn(
                              icon: Icons.remove,
                              onTap: () {
                                if (item.quantity > 1) {
                                  cart.addToCart(
                                    productId: item.productId,
                                    name: item.name,
                                    image: item.image,
                                    price: item.price,
                                    quantity: -1,
                                  );
                                } else {
                                  cart.removeItem(item.productId);
                                }
                              },
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            _qtyBtn(
                              icon: Icons.add,
                              onTap: () {
                                cart.addToCart(
                                  productId: item.productId,
                                  name: item.name,
                                  image: item.image,
                                  price: item.price,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      // ================= CHECKOUT =================
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ================= TOTAL =================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          "\$${totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ================= BUTTON =================
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF2A39),
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressSelectionScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= QTY BUTTON =================
  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFEF2A39),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ================= EMPTY CART =================
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "Your cart is empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Add delicious food to get started",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
