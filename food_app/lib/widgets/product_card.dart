import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/favorite_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==========================
          //          IMAGE
          // ==========================
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.55,
              child: Image.asset(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // ==========================
          //         CONTENT
          // ==========================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRODUCT NAME
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                // ==========================
                // RATING ⭐ + FAVORITE ❤️
                // ==========================
                Row(
                  children: [
                    // ⭐ Single star + number
                    Icon(Icons.star, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const Spacer(),

                    // ❤️ Favorite button
                    Consumer<FavoriteProvider>(
                      builder: (context, fav, _) {
                        final bool isFav = fav.isFavorite(product.id);

                        return GestureDetector(
                          onTap: () => fav.toggleFavorite(product.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? Colors.red.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFav ? Colors.red : Colors.grey.shade700,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
