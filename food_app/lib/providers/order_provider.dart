import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;

  List<dynamic> myOrders = [];
  Map<String, dynamic>? selectedOrder;

  Timer? _ordersPollingTimer;
  Timer? _orderDetailsPollingTimer;

  String? _lastOrderStatus;

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

    myOrders = await ApiService.getMyOrders();

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshMyOrders() async {
    await fetchMyOrders(force: true);
  }

  // ===============================
  // ORDERS LIST LIVE POLLING
  // ===============================
  void startPolling() {
    _ordersPollingTimer?.cancel();
    _ordersPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchMyOrders(force: true);
    });
  }

  void stopPolling() {
    _ordersPollingTimer?.cancel();
    _ordersPollingTimer = null;
  }

  // ===============================
  // FETCH ORDER BY ID (A2 FINAL FIX)
  // ===============================
  Future<void> fetchOrderById(String id) async {
    isLoading = true;
    notifyListeners();

    final apiOrder = await ApiService.getOrderById(id);

    if (apiOrder != null) {
      final order = Map<String, dynamic>.from(apiOrder);

      final newStatus = order["status"];
      final statusChanged =
          _lastOrderStatus != null && _lastOrderStatus != newStatus;

      _lastOrderStatus = newStatus;

      selectedOrder = {...order, "_statusChanged": statusChanged};

      if (newStatus == "delivered") {
        stopOrderPolling();
      }
    } else {
      selectedOrder = null;
    }

    isLoading = false;
    notifyListeners();
  }

  // ===============================
  // ORDER DETAILS LIVE POLLING
  // ===============================
  void startOrderPolling(String orderId) {
    _orderDetailsPollingTimer?.cancel();
    _orderDetailsPollingTimer = Timer.periodic(const Duration(seconds: 10), (
      _,
    ) {
      fetchOrderById(orderId);
    });
  }

  void stopOrderPolling() {
    _orderDetailsPollingTimer?.cancel();
    _orderDetailsPollingTimer = null;
  }
}
