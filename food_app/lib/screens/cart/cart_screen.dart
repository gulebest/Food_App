import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../payment/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your Cart",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),

      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => cart.removeItem(item.productId),

                  child: Row(
                    children: [
                      Image.asset(
                        item.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          // ➖ REMOVE (no removeSingleItem)
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (item.quantity > 1) {
                                cart.addToCart(
                                  productId: item.productId,
                                  name: item.name,
                                  image: item.image,
                                  price: item.price,
                                  quantity: -1, // 👈 decrement
                                );
                              } else {
                                cart.removeItem(item.productId);
                              }
                            },
                          ),

                          Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // ➕ ADD
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
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
                );
              },
            ),

      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2A39), // 🔴 RED
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // ✅ JUST NAVIGATE TO PAYMENT
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentScreen()),
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
            ),
    );
  }
}
