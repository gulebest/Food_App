import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasLoadedOnce = false;

  final List<String> _favoriteIds = [];

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  // ============================
  // LOAD PRODUCTS (ONCE)
  // ============================
  Future<void> fetchProducts() async {
    if (_hasLoadedOnce) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getProducts();

      _products = data.map<Product>((e) {
        return Product.fromJson(e);
      }).toList();

      _hasLoadedOnce = true;
    } catch (e) {
      debugPrint("❌ Fetch Products Error: $e");
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================
  // FIND BY MONGO _id
  // ============================
  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============================
  // CATEGORY FILTER
  // ============================
  List<Product> filterByCategory(String category) {
    if (category == "All") return _products;
    return _products.where((p) => p.category == category).toList();
  }

  // ============================
  // FAVORITES
  // ============================
  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    _favoriteIds.contains(id) ? _favoriteIds.remove(id) : _favoriteIds.add(id);
    notifyListeners();
  }

  List<Product> get favorites =>
      _products.where((p) => _favoriteIds.contains(p.id)).toList();
}
