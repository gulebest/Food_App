import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  Map<String, dynamic>? currentUser;

  // ---------------------------
  // AUTO LOGIN
  // ---------------------------
  Future<void> autoLogin() async {
    final token = await ApiService.loadToken();

    if (token == null) {
      isAuthenticated = false;
      currentUser = null;
      notifyListeners();
      return;
    }

    final profile = await ApiService.getProfile();

    if (profile != null) {
      currentUser = Map<String, dynamic>.from(profile);
      isAuthenticated = true;
    } else {
      await ApiService.logout();
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
      await ApiService.saveToken(res["token"]);
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
      await ApiService.saveToken(res["token"]);
      currentUser = Map<String, dynamic>.from(res["user"]);
      isAuthenticated = true;
      notifyListeners();
      return null;
    }

    return res["message"] ?? "Registration failed";
  }

  // ---------------------------
  // UPDATE PROFILE (FIXED)
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

    // ✅ SUPPORT BOTH RESPONSE SHAPES
    final updatedUser = result["user"] != null ? result["user"] : result;

    currentUser = Map<String, dynamic>.from(updatedUser);
    notifyListeners();
    return true;
  }

  // ---------------------------
  // LOGOUT
  // ---------------------------
  Future<void> logout() async {
    await ApiService.logout();
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
