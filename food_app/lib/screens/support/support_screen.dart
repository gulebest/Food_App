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
  final ScrollController _scrollController = ScrollController();

  late SupportProvider _supportProvider;
  bool _socketInitialized = false;

  @override
  void initState() {
    super.initState();
    _supportProvider = context.read<SupportProvider>();
    _init();
  }

  Future<void> _init() async {
    final token = await ApiService.loadToken();
    final userProvider = context.read<UserProvider>();

    if (!mounted || token == null) return;

    await _supportProvider.loadMessages(token);

    final userId = userProvider.currentUser?["_id"];
    if (userId != null && !_socketInitialized) {
      _supportProvider.initSocket(userId);
      _socketInitialized = true;
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final token = await ApiService.loadToken();
    if (token == null) return;

    _controller.clear();
    await _supportProvider.sendMessage(token, text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _supportProvider.disposeSocket();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final supportProvider = context.watch<SupportProvider>();
    final userId = userProvider.currentUser?["_id"];

    if (!userProvider.loggedIn) {
      return const Scaffold(
        body: Center(child: Text("Please log in to contact support")),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Support")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  supportProvider.messages.length +
                  (supportProvider.isTyping ? 1 : 0),
              itemBuilder: (_, index) {
                if (supportProvider.isTyping &&
                    index == supportProvider.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("Support is typing..."),
                  );
                }

                final msg = supportProvider.messages[index];
                final isUser = msg["sender"] == "user";
                final status = msg["status"];

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
                      color: isUser
                          ? Colors.green.shade400
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg["message"] ?? "",
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isUser) ...[
                          const SizedBox(width: 6),
                          if (status == "sending")
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.white70,
                            ),
                          if (status == "failed")
                            GestureDetector(
                              onTap: () async {
                                final token = await ApiService.loadToken();
                                if (token != null) {
                                  supportProvider.retryMessage(token, msg);
                                }
                              },
                              child: const Icon(
                                Icons.error,
                                size: 14,
                                color: Colors.yellow,
                              ),
                            ),
                          if (status == "sent")
                            const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white70,
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          SafeArea(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,

                      onChanged: (_) {
                        if (userId != null) supportProvider.emitTyping(userId);
                      },
                      onSubmitted: (_) {
                        if (userId != null)
                          supportProvider.emitStopTyping(userId);
                      },

                      decoration: const InputDecoration(
                        hintText: "Type your message…",
                        border: InputBorder.none,
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
          ),
        ],
      ),
    );
  }
}
