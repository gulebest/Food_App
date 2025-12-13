import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../popup/success_popup.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int selectedCard = 0;
  bool saveCard = true;
  bool isPaying = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  Future<void> _payNow() async {
    if (isPaying) return;

    setState(() => isPaying = true);

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final result = await orderProvider.placeOrder("Default address");

    if (!mounted) return;

    if (result["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPopup()),
      );
      return;
    }

    setState(() => isPaying = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Payment failed. Try again")));
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              _summaryRow("Order", "\$16.48"),
              _summaryRow("Taxes", "\$0.30"),
              _summaryRow("Delivery fees", "\$1.50"),
              _summaryRow("Estimated delivery time:", "15-30 mins", bold: true),
              const Divider(),
              _summaryRow("Total:", "\$18.19", bold: true),

              const SizedBox(height: 20),

              const Text(
                "Payment methods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              _paymentCard(
                index: 0,
                logo:
                    "https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png",
                title: "Credit card",
                number: "5105 **** **** 0505",
              ),
              const SizedBox(height: 12),
              _paymentCard(
                index: 1,
                logo:
                    "https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png",
                title: "Debit card",
                number: "3566 **** **** 0505",
              ),

              Row(
                children: [
                  Checkbox(
                    value: saveCard,
                    onChanged: (v) => setState(() => saveCard = v!),
                    activeColor: Colors.red,
                  ),
                  const Text("Save card for future payments"),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "\$18.19",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
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
                        : const Text("Pay Now", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard({
    required int index,
    required String logo,
    required String title,
    required String number,
  }) {
    final isSelected = selectedCard == index;

    return InkWell(
      onTap: () => setState(() => selectedCard = index),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown.shade300 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.network(
              logo,
              width: 40,
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.credit_card),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
