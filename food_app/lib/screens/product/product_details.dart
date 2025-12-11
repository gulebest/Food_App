import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetails extends StatefulWidget {
  final String productId;

  const ProductDetails({super.key, required this.productId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  double spicyLevel = 1;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final product = productProvider.findById(widget.productId);
    bool isFav = productProvider.isFavorite(product.id);

    double totalPrice = product.price * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================
            // TOP IMAGE + BUTTONS
            // ==========================
            Stack(
              children: [
                Hero(
                  tag: product.id,
                  child: Container(
                    height: 320,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(product.image, fit: BoxFit.contain),
                  ),
                ),

                // BACK BUTTON
                Positioned(
                  top: 15,
                  left: 15,
                  child: _circleBtn(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                ),

                // SEARCH BUTTON
                Positioned(
                  top: 15,
                  right: 60,
                  child: _circleBtn(Icons.search, () {}),
                ),

                // FAVORITE BUTTON
                Positioned(
                  top: 15,
                  right: 15,
                  child: _circleBtn(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    () {
                      productProvider.toggleFavorite(product.id);
                    },
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            // ==========================
            // CONTENT BODY
            // ==========================
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

                      // PRODUCT NAME
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ⭐ RATING + TIME
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "14 mins",
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // LONG DESCRIPTION
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==========================
                      // SPICY + PORTION IN SAME ROW
                      // ==========================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SPICY SECTION
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Spicy",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      "Mild",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    Text(
                                      "Hot",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: spicyLevel,
                                  min: 1,
                                  max: 3,
                                  divisions: 2,
                                  activeColor: Color(0xFFEF2A39),
                                  inactiveColor: Colors.grey.shade300,
                                  onChanged: (value) {
                                    setState(() => spicyLevel = value);
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // PORTION SECTION ON SAME ROW
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Portion",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _qtyButton(Icons.remove, () {
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  }),
                                  Container(
                                    width: 45,
                                    alignment: Alignment.center,
                                    child: Text(
                                      quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _qtyButton(Icons.add, () {
                                    setState(() => quantity++);
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // ==========================
                      // PRICE + ORDER NOW
                      // ==========================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // PRICE IN NON-CLICKABLE BUTTON STYLE
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              "\$${totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF2A39),
                              ),
                            ),
                          ),

                          // ORDER NOW BUTTON
                          SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 45,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                final cart = Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                );

                                for (int i = 0; i < quantity; i++) {
                                  cart.addToCart(
                                    productId: product.id,
                                    name: product.name,
                                    image: product.image,
                                    price: product.price,
                                  );
                                }

                                Navigator.pushNamed(context, "/payment");
                              },
                              child: const Text(
                                "ORDER NOW",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // SMALL ROUND TOP BUTTON
  // =============================
  Widget _circleBtn(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.15)),
          ],
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  // =============================
  // QTY BUTTON
  // =============================
  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFEF2A39),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
