import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  double get totalAmount {
    double total = 0;
    _items.forEach((_, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addToCart({
    required String productId,
    required String name,
    required String image,
    required double price,
    int quantity = 1,
  }) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += quantity;
    } else {
      _items[productId] = CartItem(
        productId: productId,
        name: name,
        image: image,
        price: price,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
