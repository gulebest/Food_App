import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidePass = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/auth_food.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome Back",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Login to your account",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  TextField(controller: email, decoration: _field("Email")),
                  const SizedBox(height: 18),

                  TextField(
                    controller: password,
                    obscureText: hidePass,
                    decoration: _field("Password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePass ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => hidePass = !hidePass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: _btn(),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            color: Color(0xFFEF2A39),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email & password")),
      );
      return;
    }

    setState(() => isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final message = await userProvider.login(
      email.text.trim(),
      password.text.trim(),
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  InputDecoration _field(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFEF2A39)),
      borderRadius: BorderRadius.circular(14),
    ),
  );

  ButtonStyle _btn() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFEF2A39),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}
