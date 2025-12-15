import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/stripe_service.dart';
import '../popup/success_popup.dart';
import '../address/address_selection_screen.dart';

class PaymentScreen extends StatefulWidget {
  final AddressModel selectedAddress;

  const PaymentScreen({super.key, required this.selectedAddress});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isPaying = false;

  bool _isValidMongoId(String id) {
    final regex = RegExp(r'^[a-fA-F0-9]{24}$');
    return regex.hasMatch(id);
  }

  Future<void> _payNow() async {
    if (isPaying) return;

    setState(() => isPaying = true);

    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.items.isEmpty) {
      setState(() => isPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cart is empty")));
      return;
    }

    // 🔒 Validate Mongo ObjectIds
    for (final item in cart.items.values) {
      if (!_isValidMongoId(item.productId)) {
        setState(() => isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid product detected. Refresh products."),
          ),
        );
        return;
      }
    }

    // 💳 Stripe payment (amount locked)
    final paid = await StripeService.pay((cart.totalAmount * 100).toInt());

    if (!paid) {
      setState(() => isPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Payment cancelled")));
      return;
    }

    // 📦 Delivery address snapshot
    final deliveryAddress =
        "${widget.selectedAddress.fullName}\n"
        "${widget.selectedAddress.street}\n"
        "${widget.selectedAddress.city}, ${widget.selectedAddress.country}\n"
        "${widget.selectedAddress.phone}";

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final result = await orderProvider.placeOrder(
      address: deliveryAddress,
      items: cart.itemsForOrder,
      totalAmount: cart.totalAmount,
    );

    if (!mounted) return;

    if (result["success"] == true) {
      cart.clearCart();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPopup()),
      );
      return;
    }

    setState(() => isPaying = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order failed after payment")));
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.selectedAddress;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${address.fullName}\n"
                      "${address.street}, ${address.city}\n"
                      "${address.country}\n"
                      "${address.phone}",
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${cart.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: isPaying ? null : _payNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 30,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isPaying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Pay Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
