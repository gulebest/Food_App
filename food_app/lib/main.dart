import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

// Providers
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/address/address_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Stripe publishable key
  Stripe.publishableKey =
      "pk_test_51SNId5JWhKSIeDPOAQCM5t65dcTeArpbOIjWh9BQIVpOnxD0yv3dCpDxuwpdE71UsXZQ2A1omy5X9MPINh5kOyqB00EthvbXJM";

  await Stripe.instance.applySettings();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
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
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true, // required for DevicePreview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      title: 'Food App',

      home: const SplashScreen(),

      routes: {
        '/cart': (_) => const CartScreen(),
        '/address': (_) => const AddressSelectionScreen(),
      },
    );
  }
}
