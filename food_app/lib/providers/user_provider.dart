import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = "Sophia Patel";
  String _email = "sophiapatel@gmail.com";
  String _address = "123 Main St Apartment 4A, New York, NY";
  String _password = "password123";
  String _profileImage = "assets/user.png";

  String get name => _name;
  String get email => _email;
  String get address => _address;
  String get password => _password;
  String get profileImage => _profileImage;

  void updateUser({
    String? name,
    String? email,
    String? address,
    String? password,
    String? profileImage,
  }) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    if (address != null) _address = address;
    if (password != null) _password = password;
    if (profileImage != null) _profileImage = profileImage;

    notifyListeners();
  }

  void logout() {
    _name = "";
    _email = "";
    _address = "";
    _password = "";
    _profileImage = "assets/user.png";

    notifyListeners();
  }
}
