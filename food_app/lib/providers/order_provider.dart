import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;

  List<dynamic> myOrders = [];
  Map<String, dynamic>? selectedOrder;

  Future<void> fetchMyOrders() async {
    isLoading = true;
    notifyListeners();

    myOrders = await ApiService.getMyOrders();

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrderById(String id) async {
    isLoading = true;
    notifyListeners();

    selectedOrder = await ApiService.getOrderById(id);

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> placeOrder(String address) async {
    if (isLoading) return {"success": false};

    isLoading = true;
    notifyListeners();

    final result = await ApiService.placeOrder(address);

    isLoading = false;

    if (result["success"] == true) {
      await fetchMyOrders();
    }

    notifyListeners();
    return result;
  }
}
