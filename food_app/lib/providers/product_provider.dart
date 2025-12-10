import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  // =======================================================
  // PRODUCT LIST WITH ADDED CATEGORY FIELD
  // =======================================================
  final List<Product> _products = [
    Product(
      id: "1",
      name: "Cheeseburger Wendy's",
      description:
          "Juicy grilled beef patty topped with melted cheese, crispy veggies, and soft buns.",
      image: "assets/burger1.png",
      price: 8.24,
      rating: 4.8,
      calories: "240 kcal",
      category: "Classic", // ⭐ ADDED
    ),
    Product(
      id: "2",
      name: "Veggie Burger",
      description:
          "A healthy plant-based burger with fresh lettuce, tomato, and special sauce.",
      image: "assets/burger2.png",
      price: 9.50,
      rating: 4.5,
      calories: "180 kcal",
      category: "Classic", // ⭐ ADDED
    ),
    Product(
      id: "3",
      name: "Chicken Burger",
      description:
          "Crispy chicken patty paired with mayo, lettuce, and soft buns.",
      image: "assets/burger3.png",
      price: 12.40,
      rating: 4.7,
      calories: "250 kcal",
      category: "Combos", // ⭐ ADDED
    ),
    Product(
      id: "4",
      name: "Double Beef Burger",
      description:
          "Double grilled beef patties, cheese, onions, pickles, and sesame buns.",
      image: "assets/burger4.png",
      price: 14.99,
      rating: 4.9,
      calories: "360 kcal",
      category: "Combos", // ⭐ ADDED
    ),
    Product(
      id: "5",
      name: "Spicy Burger",
      description:
          "Hot & spicy beef patty with jalapeños, chili sauce, and cheese.",
      image: "assets/burger5.png",
      price: 10.99,
      rating: 4.6,
      calories: "220 kcal",
      category: "Sliders", // ⭐ ADDED
    ),
    Product(
      id: "6",
      name: "Mushroom Swiss Burger",
      description:
          "Savory beef patty topped with sautéed mushrooms, Swiss cheese, lettuce, and our signature sauce.",
      image: "assets/burger6.png",
      price: 11.75,
      rating: 4.7,
      calories: "270 kcal",
      category: "Sliders", // ⭐ ADDED
    ),
  ];

  List<Product> get products => [..._products];

  // =======================================================
  // FIND PRODUCT BY ID
  // =======================================================
  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  // =======================================================
  // ⭐ CATEGORY FILTER
  // =======================================================
  List<Product> filterByCategory(String category) {
    if (category == "All") return products;
    return _products.where((p) => p.category == category).toList();
  }

  // =======================================================
  // FAVORITES SYSTEM (KEPT EXACTLY AS YOU WROTE)
  // =======================================================
  final List<String> _favoriteIds = [];

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  List<Product> get favorites {
    return _products.where((p) => _favoriteIds.contains(p.id)).toList();
  }
}
