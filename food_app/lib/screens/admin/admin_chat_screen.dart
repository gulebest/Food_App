import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_support_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../services/network_service.dart';

class AdminChatScreen extends StatefulWidget {
  final String userId;
  const AdminChatScreen({super.key, required this.userId});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late AdminSupportProvider _provider;
  late NetworkService _network;
  bool _socketInitialized = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<AdminSupportProvider>();
    _network = context.read<NetworkService>();
    _init();
  }

  Future<void> _init() async {
    final token = await ApiService.loadToken();
    final admin = context.read<UserProvider>().currentUser;

    if (token == null || admin == null) return;

    await _provider.loadMessages(token, widget.userId, _network);

    if (!_socketInitialized) {
      _provider.initSocket(admin["_id"], _network);
      _socketInitialized = true;
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _provider.disposeSocket();
    controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminSupportProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("User Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (provider.isTyping && i == provider.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "User is typing...",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  );
                }

                final m = provider.messages[i];
                final isAdmin = m["sender"] == "support";

                return Align(
                  alignment: isAdmin
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m["message"] ?? "",
                      style: TextStyle(
                        color: isAdmin ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          /// INPUT BAR (OFFLINE SAFE)
          SafeArea(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Reply...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      final token = await ApiService.loadToken();
                      if (token == null) return;

                      controller.clear();

                      await _provider.sendReply(
                        token,
                        widget.userId,
                        text,
                        _network,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
