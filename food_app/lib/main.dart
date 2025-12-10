import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/user_provider.dart'; // ✅ NEW — required for Profile screen

import 'screens/splash/splash_screen.dart';

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
        ChangeNotifierProvider(create: (_) => UserProvider()), // ✅ ADDED
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
