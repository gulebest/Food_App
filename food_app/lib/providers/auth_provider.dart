import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? token;
  Map<String, dynamic>? user;

  bool isLoading = false;
  bool isInitialized = false;

  bool get isAuthenticated => token != null;

  // -------------------------
  // AUTO LOGIN (OFFLINE SAFE)
  // -------------------------
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    final savedUser = prefs.getString("user");

    if (token != null && savedUser != null) {
      try {
        user = jsonDecode(savedUser);
      } catch (_) {
        user = null;
      }
    }

    // 🚫 DO NOT call backend here
    // Offline apps must trust local token

    isInitialized = true;
    notifyListeners();
  }

  // -------------------------
  // SAVE TOKEN + USER
  // -------------------------
  Future<void> _saveAuth(String t, Map<String, dynamic> u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", t);
    await prefs.setString("user", jsonEncode(u));

    token = t;
    user = u;
    notifyListeners();
  }

  // -------------------------
  // REGISTER
  // -------------------------
  Future<String?> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await ApiService.register(name, email, phone, password);

      if (res["success"] == true && res["token"] != null) {
        await _saveAuth(res["token"], res["user"]);
        return null;
      }

      return res["message"] ?? "Registration failed";
    } catch (e) {
      return "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // LOGIN
  // -------------------------
  Future<String?> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await ApiService.login(email, password);

      if (res["success"] == true && res["token"] != null) {
        await _saveAuth(res["token"], res["user"]);
        return null;
      }

      return res["message"] ?? "Invalid login";
    } catch (e) {
      return "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------
  // LOGOUT
  // -------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token = null;
    user = null;

    notifyListeners();
  }
}
