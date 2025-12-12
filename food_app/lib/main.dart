import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/payment/payment_screen.dart';
import 'screens/popup/success_popup.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/support/support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
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
        "/home": (_) => const HomeScreen(),
        "/payment": (_) => const PaymentScreen(),
        "/success": (_) => const SuccessPopup(),
        "/profile": (_) => const ProfileScreen(),
        "/support": (_) => const SupportScreen(),
      },
    );
  }
}
