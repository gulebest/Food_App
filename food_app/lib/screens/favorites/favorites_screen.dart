import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorite_provider.dart';
import '../../providers/product_provider.dart';
import '../product/product_details.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavoriteProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    final favorites = productProvider.products
        .where((p) => favProvider.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorite products yet",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (_, i) {
                final product = favorites[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Image.network(
                      product.image,
                      width: 55,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetails(productId: product.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
