import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  Map<String, dynamic>? currentUser;

  static const _userKey = "user";

  // ---------------------------
  // AUTO LOGIN (100% OFFLINE SAFE)
  // ---------------------------
  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");
    final cachedUser = prefs.getString(_userKey);

    // ❌ No session
    if (token == null || cachedUser == null) {
      isAuthenticated = false;
      currentUser = null;
      notifyListeners();
      return;
    }

    try {
      // ✅ TRUST LOCAL CACHE ONLY
      currentUser = jsonDecode(cachedUser);
      isAuthenticated = true;
    } catch (_) {
      // ❌ Corrupted cache → force logout
      await prefs.remove("token");
      await prefs.remove(_userKey);
      isAuthenticated = false;
      currentUser = null;
    }

    notifyListeners();
  }

  // ---------------------------
  // LOGIN
  // ---------------------------
  Future<String?> login(String email, String password) async {
    final res = await ApiService.login(email, password);

    if (res["success"] == true && res["token"] != null) {
      final prefs = await SharedPreferences.getInstance();

      await ApiService.saveToken(res["token"]);
      await prefs.setString(_userKey, jsonEncode(res["user"]));

      currentUser = Map<String, dynamic>.from(res["user"]);
      isAuthenticated = true;
      notifyListeners();
      return null;
    }

    return res["message"] ?? "Login failed";
  }

  // ---------------------------
  // REGISTER
  // ---------------------------
  Future<String?> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final res = await ApiService.register(name, email, phone, password);

    if (res["success"] == true && res["token"] != null) {
      final prefs = await SharedPreferences.getInstance();

      await ApiService.saveToken(res["token"]);
      await prefs.setString(_userKey, jsonEncode(res["user"]));

      currentUser = Map<String, dynamic>.from(res["user"]);
      isAuthenticated = true;
      notifyListeners();
      return null;
    }

    return res["message"] ?? "Registration failed";
  }

  // ---------------------------
  // UPDATE PROFILE
  // ---------------------------
  Future<bool> updateUserProfile({
    required String name,
    required String address,
    String? password,
    File? avatarFile,
  }) async {
    final result = await ApiService.updateProfileMultipart(
      name: name,
      address: address,
      password: password,
      avatarFile: avatarFile,
    );

    if (result == null) return false;

    final updatedUser = result["user"] ?? result;
    currentUser = Map<String, dynamic>.from(updatedUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(currentUser));

    notifyListeners();
    return true;
  }

  // ---------------------------
  // LOGOUT
  // ---------------------------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove(_userKey);

    isAuthenticated = false;
    currentUser = null;
    notifyListeners();
  }

  // ---------------------------
  // GETTERS
  // ---------------------------
  String get name => currentUser?["name"] ?? "";
  String get email => currentUser?["email"] ?? "";
  String get address => currentUser?["address"] ?? "";
  bool get loggedIn => isAuthenticated;
}
