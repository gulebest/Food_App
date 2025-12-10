import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/favorite_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final double rating = product.rating;
    final int fullStars = rating.floor();
    final bool halfStar = rating - fullStars >= 0.5;

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
          // =====================
          //       IMAGE
          // =====================
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

          // =====================
          //       CONTENT
          // =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                // =====================
                //  RATING + FAVORITE
                // =====================
                Row(
                  children: [
                    // ⭐ RATING STARS ⭐
                    Row(
                      children: [
                        ...List.generate(fullStars, (index) {
                          return const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          );
                        }),

                        if (halfStar)
                          const Icon(
                            Icons.star_half,
                            size: 16,
                            color: Colors.orange,
                          ),

                        ...List.generate(
                          5 - fullStars - (halfStar ? 1 : 0),
                          (index) => const Icon(
                            Icons.star_border,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ❤️ FAVORITE BUTTON
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
