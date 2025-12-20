import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_support_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../services/network_service.dart';
import 'admin_chat_screen.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  late AdminSupportProvider _provider;
  late NetworkService _network;

  @override
  void initState() {
    super.initState();
    _provider = context.read<AdminSupportProvider>();
    _network = context.read<NetworkService>();
    _load();
  }

  Future<void> _load() async {
    final token = await ApiService.loadToken();
    if (token == null) return;

    await _provider.loadConversations(token, _network);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminSupportProvider>();
    final user = context.watch<UserProvider>().currentUser;

    if (user?["isAdmin"] != true) {
      return const Scaffold(body: Center(child: Text("Admin access only")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Support Dashboard")),
      body: SafeArea(
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: provider.conversations.length,
                itemBuilder: (_, i) {
                  final c = provider.conversations[i];
                  return ListTile(
                    title: Text("User: ${c["_id"]}"),
                    subtitle: Text(c["lastMessage"] ?? ""),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminChatScreen(userId: c["_id"]),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
