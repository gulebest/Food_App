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

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final product = productProvider.findById(widget.productId);
    bool isFav = productProvider.isFavorite(product.id);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Ensures normal back navigation
        return false; // Prevents app from closing
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ============================
              // TOP IMAGE + BACK BUTTON
              // ============================
              Stack(
                children: [
                  Hero(
                    tag: product.id,
                    child: Container(
                      height: 310,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(product.image, fit: BoxFit.contain),
                    ),
                  ),

                  // BACK BUTTON
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _circleBtn(
                      Icons.arrow_back,
                      () => Navigator.pop(context),
                    ),
                  ),

                  // FAVORITE BUTTON
                  Positioned(
                    top: 10,
                    right: 10,
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

              // ============================
              // CONTENT AREA
              // ============================
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
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

                        const SizedBox(height: 12),

                        // RATING + CALORIES
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 22,
                                color: index < product.rating
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Text(
                              product.calories,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // DESCRIPTION
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // PRICE + QUANTITY
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${product.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF2A39),
                              ),
                            ),

                            Row(
                              children: [
                                _qtyButton(Icons.remove, () {
                                  if (quantity > 1) {
                                    setState(() => quantity--);
                                  }
                                }),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
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

                        const SizedBox(height: 25),

                        // ADD TO CART BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF2A39),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.black87,
                                  content: Text(
                                    "${product.name} added to cart",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Add to Cart",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
      ),
    );
  }

  // BUTTONS
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
            BoxShadow(blurRadius: 5, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }
}
