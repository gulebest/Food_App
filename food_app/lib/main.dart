import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/user_provider.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/popup/success_popup.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/support/support_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        // First opening screen
        home: const SplashScreen(),

        // Global app routes
        routes: {
          "/home": (context) => const HomeScreen(),
          "/payment": (context) => const PaymentScreen(),
          "/success": (context) => const SuccessPopup(),
          "/profile": (context) => const ProfileScreen(),
          "/support": (context) => const SupportScreen(),
        },

        // Better transition + popup handling
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
