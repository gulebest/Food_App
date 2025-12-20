import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../../utils/image_converter.dart';
import '../admin/admin_support_screen.dart'; // 🆕 ADD

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _uploading = false;

  File? _pickedImage;

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController passwordCtrl;

  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _lastUser;

  static const String baseUrl = "http://192.168.137.22:5000";

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    addressCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
  }

  void _syncUser(UserProvider user) {
    if (user.currentUser == null || user.currentUser == _lastUser) return;
    _lastUser = user.currentUser;
    nameCtrl.text = user.currentUser?["name"] ?? "";
    emailCtrl.text = user.currentUser?["email"] ?? "";
    addressCtrl.text = user.currentUser?["address"] ?? "";
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final jpg = await ImageConverter.ensureJpg(File(image.path));
      setState(() => _pickedImage = jpg);
    }
  }

  Future<void> _pickFromCamera() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final jpg = await ImageConverter.ensureJpg(File(image.path));
      setState(() => _pickedImage = jpg);
    }
  }

  ImageProvider _profileImage(UserProvider user) {
    if (_pickedImage != null) {
      return FileImage(_pickedImage!);
    }

    final img = user.currentUser?["profileImage"];
    if (img != null && img.toString().startsWith("/uploads")) {
      return NetworkImage(
        "$baseUrl$img?v=${DateTime.now().millisecondsSinceEpoch}",
      );
    }

    return const AssetImage("assets/profile.png");
  }

  void _openAvatarPreview(UserProvider user) {
    showDialog(
      context: context,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image(image: _profileImage(user), fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo),
                      label: const Text("Change photo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      color: Colors.white,
                      iconSize: 28,
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    _syncUser(user);

    final isAdmin = user.currentUser?["isAdmin"] == true; // 🆕

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openAvatarPreview(user),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: _profileImage(user),
                    backgroundColor: Colors.grey[300],
                  ),
                  if (_uploading)
                    const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _input("Name", nameCtrl, enabled: _editing),
            _input("Email", emailCtrl, enabled: false),
            _input("Address", addressCtrl, enabled: _editing),
            _input("Password", passwordCtrl, enabled: _editing, obscure: true),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _uploading
                  ? null
                  : () async {
                      if (_editing) {
                        setState(() => _uploading = true);

                        final ok = await user.updateUserProfile(
                          name: nameCtrl.text,
                          address: addressCtrl.text,
                          password: passwordCtrl.text.isEmpty
                              ? null
                              : passwordCtrl.text,
                          avatarFile: _pickedImage,
                        );

                        setState(() => _uploading = false);
                        if (!ok) return;

                        _pickedImage = null;
                        passwordCtrl.clear();
                      }

                      setState(() => _editing = !_editing);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _editing ? Colors.green : Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(_editing ? "Save" : "Edit"),
            ),

            // 🆕 ADMIN SUPPORT BUTTON
            if (isAdmin) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text("Admin Support Dashboard"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSupportScreen(),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () async {
                await user.logout();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool enabled = false,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        obscureText: obscure,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }
}
