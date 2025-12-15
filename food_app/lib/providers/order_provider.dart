import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;

  List<dynamic> myOrders = [];
  Map<String, dynamic>? selectedOrder;

  Future<Map<String, dynamic>> placeOrder({
    required String address,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    if (isLoading) return {"success": false};

    isLoading = true;
    notifyListeners();

    final result = await ApiService.placeOrder(
      address: address,
      items: items,
      totalAmount: totalAmount,
    );

    isLoading = false;

    if (result["success"] == true) {
      await fetchMyOrders();
    }

    notifyListeners();
    return result;
  }

  Future<void> fetchMyOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      myOrders = await ApiService.getMyOrders();
    } catch (_) {
      myOrders = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderById(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      selectedOrder = await ApiService.getOrderById(id);
    } catch (_) {
      selectedOrder = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
