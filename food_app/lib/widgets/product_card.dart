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
          // ================= IMAGE =================
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: AspectRatio(
              aspectRatio: 1.55,
              child: Image.network(
                product.image, // ✅ FROM MONGODB
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.fastfood, size: 40),
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                Row(
                  children: [
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

                    Consumer<FavoriteProvider>(
                      builder: (_, fav, __) {
                        final isFav = fav.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () => fav.toggleFavorite(product.id),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
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
