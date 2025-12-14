import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../providers/order_provider.dart';
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

  Future<void> _payNow() async {
    if (isPaying) return;

    setState(() => isPaying = true);
    print("🟡 Pay Now button pressed");

    // 💳 Stripe payment ($18.19 → 1819 cents)
    final paid = await StripeService.pay(1819);

    print("🟡 Stripe payment result: $paid");

    if (!paid) {
      setState(() => isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment cancelled or failed")),
      );
      return;
    }

    print("🟢 Payment successful, placing order");

    // 📦 Place order
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final deliveryAddress =
        "${widget.selectedAddress.fullName}\n"
        "${widget.selectedAddress.street}\n"
        "${widget.selectedAddress.city}, ${widget.selectedAddress.country}\n"
        "${widget.selectedAddress.phone}";

    final result = await orderProvider.placeOrder(deliveryAddress);

    print("🟢 Order response: $result");

    if (!mounted) return;

    if (result["success"] == true) {
      print("✅ Order placed successfully, navigating to success screen");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPopup()),
      );
      return;
    }

    print("❌ Order failed");

    setState(() => isPaying = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order failed after payment")));
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.selectedAddress;

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
                      style: const TextStyle(fontSize: 14),
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
                const Text(
                  "\$18.19",
                  style: TextStyle(
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
