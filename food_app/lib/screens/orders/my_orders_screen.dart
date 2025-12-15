import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../home/home_screen.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrderProvider>(context, listen: false);

      provider.fetchMyOrders(force: true);
      provider.startPolling(); // 🔄 LIVE REFRESH
    });
  }

  @override
  void dispose() {
    Provider.of<OrderProvider>(context, listen: false).stopPolling();
    super.dispose();
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

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text("My Orders"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goHome(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: provider.refreshMyOrders,
          child: provider.isLoading && provider.myOrders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : provider.myOrders.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text("No orders yet")),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: provider.myOrders.length,
                  itemBuilder: (_, i) {
                    final order = provider.myOrders[i];
                    final id = order["_id"].toString().substring(0, 8);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          "Order #$id",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Total: \$${(order["totalAmount"] as num).toStringAsFixed(2)}",
                        ),
                        trailing: Chip(
                          backgroundColor: _statusColor(
                            order["status"] ?? "pending",
                          ),
                          label: Text(
                            order["status"] ?? "pending",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailsScreen(orderId: order["_id"]),
                            ),
                          );

                          provider.refreshMyOrders();
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
