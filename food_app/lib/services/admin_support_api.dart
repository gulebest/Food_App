import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminSupportApi {
  static const baseUrl = "http://192.168.137.22:5000";

  // ===============================
  // GET ALL CONVERSATIONS (OFFLINE SAFE)
  // ===============================
  static Future<List<dynamic>> getConversations(String token) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/support/admin"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (_) {
      // OFFLINE / NETWORK ERROR
    }
    return [];
  }

  // ===============================
  // GET USER MESSAGES (OFFLINE SAFE)
  // ===============================
  static Future<List<dynamic>> getMessages(String token, String userId) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/support/admin/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (_) {
      // OFFLINE / NETWORK ERROR
    }
    return [];
  }

  // ===============================
  // ADMIN REPLY (OFFLINE SAFE)
  // ===============================
  static Future<bool> reply(String token, String userId, String message) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/support/admin/reply"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"userId": userId, "message": message}),
      );

      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
