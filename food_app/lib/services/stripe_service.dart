import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

class StripeService {
  static Future<bool> pay(int amount) async {
    try {
      print("🟡 Creating PaymentIntent for amount: $amount");

      // 1️⃣ Create PaymentIntent from backend
      final clientSecret = await ApiService.createPaymentIntent(amount);

      if (clientSecret == null || clientSecret.isEmpty) {
        print("❌ No client secret received from backend");
        return false;
      }

      print("🟢 Client secret received");

      // 2️⃣ Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Food App",
          style: ThemeMode.light,
        ),
      );

      print("🟢 PaymentSheet initialized");

      // 3️⃣ Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      print("✅ Stripe payment successful");
      return true;
    } on StripeException catch (e) {
      print("❌ StripeException: ${e.error.localizedMessage}");
      return false;
    } catch (e) {
      print("❌ Unknown Stripe error: $e");
      return false;
    }
  }
}
