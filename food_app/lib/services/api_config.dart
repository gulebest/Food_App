import 'dart:io';

class ApiConfig {
  // -------------------------
  // BASE URL
  // -------------------------
  static String get baseUrl {
    if (Platform.isAndroid) {
      // If running on Android emulator → host PC = 10.0.2.2
      return "http://10.0.2.2:5000/api";
    } else if (Platform.isIOS) {
      return "http://localhost:5000/api";
    } else {
      // REAL DEVICE → MUST use your laptop WiFi IP
      return "http://192.168.137.152:5000/api"; // ✅ your confirmed working IP
    }
  }

  // AUTH
  static String get register => "$baseUrl/auth/register";
  static String get login => "$baseUrl/auth/login";
  static String get me => "$baseUrl/auth/me";

  // PRODUCTS
  static String get products => "$baseUrl/products";

  // CART
  static String get cart => "$baseUrl/cart";

  // ORDERS
  static String get orders => "$baseUrl/orders";
}
