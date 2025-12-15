import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;

  List<dynamic> myOrders = [];
  Map<String, dynamic>? selectedOrder;

  // ===============================
  // PLACE ORDER
  // ===============================
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
      await fetchMyOrders(force: true);
    }

    notifyListeners();
    return result;
  }

  // ===============================
  // FETCH MY ORDERS
  // ===============================
  Future<void> fetchMyOrders({bool force = false}) async {
    if (isLoading && !force) return;

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

  // ===============================
  // FETCH ORDER BY ID
  // ===============================
  Future<void> fetchOrderById(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final order = await ApiService.getOrderById(id);
      selectedOrder = order;
    } catch (_) {
      selectedOrder = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
