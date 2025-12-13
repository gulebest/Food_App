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
    Provider.of<OrderProvider>(context, listen: false).fetchMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.myOrders.isEmpty
          ? const Center(child: Text("No orders yet"))
          : ListView.builder(
              itemCount: provider.myOrders.length,
              itemBuilder: (_, i) {
                final order = provider.myOrders[i];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Order #${order["_id"]}"),
                    subtitle: Text("Total: \$${order["totalAmount"]}"),
                    trailing: Chip(label: Text(order["status"])),
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
