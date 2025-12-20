import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../services/admin_support_api.dart';
import '../services/network_service.dart';

class AdminSupportProvider extends ChangeNotifier {
  final String baseUrl = "http://192.168.137.22:5000";

  List<dynamic> conversations = [];
  List<dynamic> messages = [];

  IO.Socket? socket;
  bool loading = false;
  bool isTyping = false;

  bool _socketInitialized = false;

  // ===============================
  // LOAD CONVERSATIONS (OFFLINE SAFE)
  // ===============================
  Future<void> loadConversations(String token, NetworkService network) async {
    if (!network.isOnline) {
      conversations = [];
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    conversations = await AdminSupportApi.getConversations(token);

    loading = false;
    notifyListeners();
  }

  // ===============================
  // LOAD USER MESSAGES (OFFLINE SAFE)
  // ===============================
  Future<void> loadMessages(
    String token,
    String userId,
    NetworkService network,
  ) async {
    if (!network.isOnline) {
      messages = [];
      notifyListeners();
      return;
    }

    messages = await AdminSupportApi.getMessages(token, userId);
    notifyListeners();
  }

  // ===============================
  // INIT SOCKET (OFFLINE SAFE)
  // ===============================
  void initSocket(String adminId, NetworkService network) {
    if (!network.isOnline) return;
    if (_socketInitialized) return;

    _socketInitialized = true;

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint("🟢 Admin socket connected");
      socket!.emit("join", adminId);
    });

    socket!.off("new_message");
    socket!.off("remove_message");
    socket!.off("typing");
    socket!.off("stop_typing");

    socket!.on("new_message", (data) {
      final incoming = Map<String, dynamic>.from(data);

      final exists = messages.any((m) => m["_id"] == incoming["_id"]);
      if (exists) return;

      messages.add(incoming);
      notifyListeners();
    });

    socket!.on("remove_message", (id) {
      messages.removeWhere((m) => m["_id"] == id);
      notifyListeners();
    });

    socket!.on("typing", (_) {
      isTyping = true;
      notifyListeners();
    });

    socket!.on("stop_typing", (_) {
      isTyping = false;
      notifyListeners();
    });
  }

  // ===============================
  // SEND ADMIN MESSAGE (OFFLINE SAFE)
  // ===============================
  Future<bool> sendReply(
    String token,
    String userId,
    String text,
    NetworkService network,
  ) async {
    if (!network.isOnline) return false;
    return await AdminSupportApi.reply(token, userId, text);
  }

  // ===============================
  // CLEANUP
  // ===============================
  void disposeSocket() {
    _socketInitialized = false;
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
