import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchMyOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "preparing":
        return Colors.blue;
      case "on_the_way":
        return Colors.purple;
      case "delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("My Orders"), centerTitle: true),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.myOrders.isEmpty
          ? const Center(child: Text("No orders yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.myOrders.length,
              itemBuilder: (_, i) {
                final order = provider.myOrders[i];
                final id = order["_id"].toString().substring(0, 8);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    title: Text("Order #$id"),
                    subtitle: Text(
                      "Total: \$${order["totalAmount"].toStringAsFixed(2)}",
                    ),
                    trailing: Chip(
                      backgroundColor: _statusColor(order["status"]),
                      label: Text(
                        order["status"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsScreen(orderId: order["_id"]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
