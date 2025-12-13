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
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).fetchOrderById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final order = provider.selectedOrder;

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: provider.isLoading || order == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                OrderStatusStepper(status: order["status"]),
                Expanded(
                  child: ListView.builder(
                    itemCount: order["items"].length,
                    itemBuilder: (_, i) {
                      final item = order["items"][i];
                      return ListTile(
                        title: Text(item["product"]["name"]),
                        subtitle: Text(
                          "Qty: ${item["quantity"]} × \$${item["price"]}",
                        ),
                        trailing: Text("\$${item["quantity"] * item["price"]}"),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
