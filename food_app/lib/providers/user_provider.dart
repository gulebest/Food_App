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

    // Many backends return user directly for /me, not wrapped in {user: ...}
    if (profile != null) {
      currentUser = profile; // assume profile is the user object
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
  // returns null on success, or error message
  // ---------------------------
  Future<String?> login(String email, String password) async {
    try {
      final res = await ApiService.login(email, password);

      if (res["success"] == true && res["token"] != null) {
        await ApiService.saveToken(res["token"]);
        currentUser = res["user"];
        isAuthenticated = true;
        notifyListeners();
        return null;
      }

      return res["message"] ?? "Login failed";
    } catch (e) {
      return "Login error: $e";
    }
  }

  // ---------------------------
  // REGISTER
  // returns null on success, or error message
  // ---------------------------
  Future<String?> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final res = await ApiService.register(name, email, phone, password);

      if (res["success"] == true && res["token"] != null) {
        await ApiService.saveToken(res["token"]);
        currentUser = res["user"];
        isAuthenticated = true;
        notifyListeners();
        return null;
      }

      return res["message"] ?? "Registration failed";
    } catch (e) {
      return "Registration error: $e";
    }
  }

  // ---------------------------
  // UPDATE PROFILE
  // ---------------------------
  Future<bool> updateUserProfile({
    required String name,
    required String email,
    required String address,
    required String password,
  }) async {
    final result = await ApiService.updateProfile(
      name: name,
      email: email,
      address: address,
      password: password,
    );

    if (result != null && result["user"] != null) {
      currentUser = result["user"];
      notifyListeners();
      return true;
    }

    return false;
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
  String get profileImage => "assets/images/profile.png";

  bool get loggedIn => isAuthenticated;
}
