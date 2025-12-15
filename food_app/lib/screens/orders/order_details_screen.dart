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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrderProvider>(
        context,
        listen: false,
      ).fetchOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.selectedOrder;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Order Details"), centerTitle: true),
      body: provider.isLoading || order == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                OrderStatusStepper(status: order["status"]),

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
                        "\$${(order["totalAmount"] as num).toStringAsFixed(2)}",
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
                    itemCount: order["items"].length,
                    itemBuilder: (_, i) {
                      final item = order["items"][i];
                      final product = item["product"];
                      final qty = item["quantity"] ?? 1;

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
                            product["name"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Qty: $qty × \$${item["price"]}"),
                          trailing: Text(
                            "\$${(qty * item["price"]).toStringAsFixed(2)}",
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
