import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/address/address_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 STRIPE PUBLISHABLE KEY (REAL, CORRECT)
  Stripe.publishableKey =
      "pk_test_51SNId5JWhKSIeDPOAQCM5t65dcTeArpbOIjWh9BQIVpOnxD0yv3dCpDxuwpdE71UsXZQ2A1omy5X9MPINh5kOyqB00EthvbXJM";

  // ✅ REQUIRED FOR STRIPE TO WORK
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        "/cart": (_) => const CartScreen(),
        "/address": (_) => const AddressSelectionScreen(),
      },
    );
  }
}
