import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'api_service.dart';

class StripeService {
  StripeService._();

  static Future<bool> pay(int amountInCents) async {
    try {
      // 1️⃣ Create PaymentIntent on backend
      final clientSecret = await ApiService.createPaymentIntent(amountInCents);

      if (clientSecret == null) {
        debugPrint("❌ Failed to create payment intent");
        return false;
      }

      // 2️⃣ Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Food App",
          style: ThemeMode.light,
        ),
      );

      // 3️⃣ Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint("✅ Payment successful");
      return true;
    } on StripeException catch (e) {
      debugPrint("❌ Stripe error: ${e.error.localizedMessage}");
      return false;
    } catch (e) {
      debugPrint("❌ Payment error: $e");
      return false;
    }
  }
}
