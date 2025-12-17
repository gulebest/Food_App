import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/support_provider.dart';
import '../../services/api_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await ApiService.loadToken();
    if (token == null) return;

    final supportProvider = Provider.of<SupportProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await supportProvider.loadMessages(token);

    final userId = userProvider.currentUser?["_id"];
    if (userId != null) {
      supportProvider.initSocket(userId);
    }
  }

  @override
  void dispose() {
    Provider.of<SupportProvider>(context, listen: false).disposeSocket();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final token = await ApiService.loadToken();
    if (token == null) return;

    _controller.clear();
    Provider.of<SupportProvider>(
      context,
      listen: false,
    ).sendMessage(token, text);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final supportProvider = Provider.of<SupportProvider>(context);

    if (!userProvider.loggedIn) {
      return const Scaffold(
        body: Center(child: Text("Please log in to contact support")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Support")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  supportProvider.messages.length +
                  (supportProvider.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (supportProvider.isTyping &&
                    index == supportProvider.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("Support is typing..."),
                  );
                }

                final msg = supportProvider.messages[index];
                final isUser = msg["sender"] == "user";
                final failed = msg["failed"] == true;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: failed
                          ? Colors.red.shade300
                          : isUser
                          ? Colors.green.shade400
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["message"],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => supportProvider.emitTyping(),
                    onSubmitted: (_) => supportProvider.emitStopTyping(),
                    decoration: const InputDecoration(
                      hintText: "Type your message…",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
