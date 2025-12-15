import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.137.122:5000/api";

  // ======================
  // TOKEN STORAGE
  // ======================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ======================
  // HEADERS
  // ======================

  static Future<Map<String, String>> headers({bool auth = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (auth && (token == null || token.isEmpty)) {
      print("❌ AUTH TOKEN MISSING");
    }

    return {
      "Content-Type": "application/json",
      if (auth && token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  static dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {"message": body};
    }
  }

  // =====================================================
  // AUTH
  // =====================================================

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: await headers(),
        body: jsonEncode({
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
        }),
      );

      final body = _safeDecode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {"success": true, "token": body["token"], "user": body["user"]};
      }

      return {"success": false, "message": body["message"]};
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: await headers(),
        body: jsonEncode({"email": email, "password": password}),
      );

      final body = _safeDecode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {"success": true, "token": body["token"], "user": body["user"]};
      }

      return {"success": false, "message": body["message"]};
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/auth/me"),
        headers: await headers(auth: true),
      );

      if (res.statusCode == 200) {
        return _safeDecode(res.body);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProfile({
    required String name,
    required String email,
    required String address,
    required String password,
  }) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/auth/update-profile"),
        headers: await headers(auth: true),
        body: jsonEncode({
          "name": name,
          "email": email,
          "address": address,
          "password": password,
        }),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return _safeDecode(res.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // =====================================================
  // ADDRESSES
  // =====================================================

  static Future<List<dynamic>> getAddresses() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/addresses"),
        headers: await headers(auth: true),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addAddress(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/addresses"),
        headers: await headers(auth: true),
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ============================
  // STRIPE PAYMENT
  // ============================

  static Future<String?> createPaymentIntent(int amount) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/payments/create-intent"),
        headers: await headers(auth: true),
        body: jsonEncode({"amount": amount}),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return body["clientSecret"];
      }

      return null;
    } catch (e) {
      print("PaymentIntent error: $e");
      return null;
    }
  }

  // =====================================================
  // ORDERS
  // =====================================================

  static Future<Map<String, dynamic>> placeOrder({
    required String address,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/orders/place"),
        headers: await headers(auth: true),
        body: jsonEncode({
          "deliveryAddress": address,
          "items": items,
          "totalAmount": totalAmount,
        }),
      );

      final body = _safeDecode(res.body);

      if (res.statusCode == 201) {
        return {"success": true, "order": body["order"]};
      }

      return {"success": false, "message": body["message"]};
    } catch (_) {
      return {"success": false, "message": "Network error"};
    }
  }

  static Future<List<dynamic>> getMyOrders() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/orders/my"),
        headers: await headers(auth: true),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  // 🔥 FIXED: sanitize numeric values
  static Future<Map<String, dynamic>?> getOrderById(String id) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/orders/$id"),
        headers: await headers(auth: true),
      );

      if (res.statusCode == 200) {
        final order = jsonDecode(res.body);

        order["totalAmount"] =
            (order["totalAmount"] as num?)?.toDouble() ?? 0.0;

        if (order["items"] is List) {
          for (final item in order["items"]) {
            item["quantity"] = (item["quantity"] as num?)?.toInt() ?? 1;
            item["price"] = (item["price"] as num?)?.toDouble() ?? 0.0;
          }
        }

        return order;
      }

      return null;
    } catch (e) {
      print("❌ Get order by ID error: $e");
      return null;
    }
  }

  // =============================
  // PRODUCTS
  // =============================

  static Future<List<dynamic>> getProducts() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/products"),
        headers: await headers(),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is List) return decoded;
        if (decoded is Map && decoded.containsKey("products")) {
          return decoded["products"];
        }
      }

      return [];
    } catch (e) {
      print("❌ Get products error: $e");
      return [];
    }
  }
}
