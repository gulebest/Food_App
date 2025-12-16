import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../widgets/order_status_stepper.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String? _previousStatus;

  late OrderProvider _orderProvider; // ✅ cached provider

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _orderProvider.fetchOrderById(widget.orderId);
      _orderProvider.startOrderPolling(widget.orderId);
    });
  }

  @override
  void dispose() {
    _orderProvider.stopOrderPolling(); // ✅ SAFE
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.selectedOrder;

    if (order != null) {
      final currentStatus = order["status"];
      final statusChanged = order["_statusChanged"] == true;

      if (statusChanged && currentStatus != _previousStatus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                currentStatus == "delivered"
                    ? "🎉 Order delivered successfully!"
                    : "Order status updated to \"$currentStatus\"",
              ),
              backgroundColor: currentStatus == "delivered"
                  ? Colors.green
                  : Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        });

        _previousStatus = currentStatus;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Order Details"), centerTitle: true),
      body: provider.isLoading || order == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                OrderStatusStepper(status: order["status"] ?? "pending"),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Items",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${((order["totalAmount"] ?? 0) as num).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFEF2A39),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: (order["items"] as List).length,
                    itemBuilder: (_, i) {
                      final item = order["items"][i] as Map<String, dynamic>;
                      final product = item["product"] as Map<String, dynamic>?;

                      final qty = (item["quantity"] ?? 1) as num;
                      final price = (item["price"] ?? 0) as num;
                      final name = product?["name"] ?? "Item";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Qty: $qty × \$${price.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "\$${(qty * price).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF2A39),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
