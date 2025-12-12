import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullname = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool hidePass = true;
  bool hideConfirm = true;
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
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Join our food community!",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _input(fullname, "Full Name"),
                    const SizedBox(height: 18),

                    _input(
                      email,
                      "Email",
                      validator: (v) {
                        if (v!.isEmpty) return "Enter email";
                        if (!v.contains("@")) return "Invalid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _input(
                      phone,
                      "Phone Number",
                      keyboard: TextInputType.phone,
                      validator: (v) {
                        if (v!.length < 9) return "Invalid phone";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    _password(
                      password,
                      "Password",
                      hidePass,
                      () => setState(() => hidePass = !hidePass),
                    ),
                    const SizedBox(height: 18),

                    _password(
                      confirm,
                      "Confirm Password",
                      hideConfirm,
                      () => setState(() => hideConfirm = !hideConfirm),
                      validator: (v) {
                        if (v!.isEmpty) return "Confirm password";
                        if (v != password.text) return "Passwords do not match";
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: _btn(),
                        onPressed: isLoading ? null : _register,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "CREATE ACCOUNT",
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
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: const Text(
                            "Login",
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: _field(label),
      validator: validator ?? (v) => v!.isEmpty ? "Enter $label" : null,
    );
  }

  Widget _password(
    TextEditingController ctrl,
    String label,
    bool hide,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: hide,
      decoration: _field(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
      validator: validator ?? (v) => v!.length < 6 ? "Min 6 characters" : null,
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final message = await auth.register(
      fullname.text.trim(),
      email.text.trim(),
      phone.text.trim(),
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
