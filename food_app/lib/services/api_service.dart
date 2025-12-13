import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.137.152:5000/api";

  // TOKEN STORAGE
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

  // HEADERS
  static Future<Map<String, String>> headers({bool auth = false}) async {
    String? token = await loadToken();
    return {
      "Content-Type": "application/json",
      if (auth && token != null) "Authorization": "Bearer $token",
    };
  }

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {"message": body};
    }
  }

  //---------------------------
  // REGISTER
  //---------------------------
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

  //---------------------------
  // LOGIN
  //---------------------------
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

  //---------------------------
  // GET PROFILE
  //---------------------------
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

  //---------------------------
  // UPDATE PROFILE
  //---------------------------
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
  // ORDERS
  // =====================================================

  // PLACE ORDER
  static Future<Map<String, dynamic>> placeOrder(String deliveryAddress) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/orders/place"),
        headers: await headers(auth: true),
        body: jsonEncode({"deliveryAddress": deliveryAddress}),
      );

      final body = _safeDecode(res.body);

      if (res.statusCode == 201) {
        return {"success": true, "order": body["order"]};
      }

      return {"success": false, "message": body["message"]};
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  // GET MY ORDERS
  static Future<List<dynamic>> getMyOrders() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/orders"),
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

  // GET ORDER BY ID
  static Future<Map<String, dynamic>?> getOrderById(String id) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/orders/$id"),
        headers: await headers(auth: true),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
