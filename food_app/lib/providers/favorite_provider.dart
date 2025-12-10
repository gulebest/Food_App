import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  List<String> get allFavorites => _favoriteIds.toList();
}
