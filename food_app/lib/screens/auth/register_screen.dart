import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../home/home_screen.dart'; // <-- UPDATE THIS TO YOUR HOME PAGE

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP BANNER IMAGE
            Container(
              width: double.infinity,
              height: 260,
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
                    // FULL NAME
                    TextFormField(
                      controller: fullname,
                      decoration: _input("Full Name"),
                      validator: (v) =>
                          v!.isEmpty ? "Enter your full name" : null,
                    ),
                    const SizedBox(height: 18),

                    // EMAIL
                    TextFormField(
                      controller: email,
                      decoration: _input("Email"),
                      validator: (v) {
                        if (v!.isEmpty) return "Enter your email";
                        if (!v.contains("@")) return "Invalid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // PHONE NUMBER
                    TextFormField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      decoration: _input("Phone Number"),
                      validator: (v) =>
                          v!.length < 9 ? "Enter a valid phone number" : null,
                    ),
                    const SizedBox(height: 18),

                    // PASSWORD
                    TextFormField(
                      controller: password,
                      obscureText: hidePassword,
                      decoration: _input("Password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => hidePassword = !hidePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return "Enter password";
                        if (v.length < 6) return "Min 6 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller: confirm,
                      obscureText: hideConfirm,
                      decoration: _input("Confirm Password").copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => hideConfirm = !hideConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return "Confirm your password";
                        if (v != password.text) return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // CREATE ACCOUNT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: _btnStyle(),
                        onPressed: isLoading ? null : _registerUser,
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

                    const SizedBox(height: 18),

                    // GO TO LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          },
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

  // ============================
  // REGISTER LOGIC
  // ============================
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // Fake delay (Simulating API call)
      await Future.delayed(const Duration(seconds: 1));

      setState(() => isLoading = false);

      // SUCCESS → GO DIRECTLY TO HOME
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // ============================
  // STYLES
  // ============================
  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFEF2A39)),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFEF2A39),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
