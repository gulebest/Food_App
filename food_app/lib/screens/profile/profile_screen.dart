import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController passwordCtrl;

  @override
  void initState() {
    super.initState();

    final user = Provider.of<UserProvider>(context, listen: false);

    nameCtrl = TextEditingController(text: user.currentUser?["name"] ?? "");
    emailCtrl = TextEditingController(text: user.currentUser?["email"] ?? "");
    addressCtrl = TextEditingController(
      text: user.currentUser?["address"] ?? "",
    );
    passwordCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF2A9D), Color(0xFFEF2A39)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
                SizedBox(height: 14),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _input("Name", nameCtrl, enabled: _editing),
                  const SizedBox(height: 16),

                  _input("Email", emailCtrl, enabled: _editing),
                  const SizedBox(height: 16),

                  _input("Delivery address", addressCtrl, enabled: _editing),
                  const SizedBox(height: 16),

                  _input(
                    "Password (leave blank to keep)",
                    passwordCtrl,
                    enabled: _editing,
                    obscure: true,
                  ),
                  const SizedBox(height: 24),

                  _navTile("Payment Details", Icons.credit_card),
                  const SizedBox(height: 10),

                  _navTile("Order history", Icons.history),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_editing) {
                              final ok = await user.updateUserProfile(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                password: passwordCtrl.text.trim(),
                              );

                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to update"),
                                  ),
                                );
                                return;
                              }

                              passwordCtrl.clear();
                            }

                            setState(() => _editing = !_editing);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _editing
                                ? Colors.green
                                : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _editing ? "Save" : "Edit Profile",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      ElevatedButton(
                        onPressed: () {
                          Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).logout();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.red,
                              width: 1.3,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Log out",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String title,
    TextEditingController ctrl, {
    bool enabled = false,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navTile(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Icon(icon, color: Colors.grey),
        ],
      ),
    );
  }
}
