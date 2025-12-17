import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SupportProvider extends ChangeNotifier {
  final String baseUrl = "http://192.168.137.22:5000";

  List<Map<String, dynamic>> messages = [];
  bool loading = false;
  bool isTyping = false;

  IO.Socket? socket;

  // ===============================
  // INIT SOCKET
  // ===============================
  void initSocket(String userId) {
    socket ??= IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint("🟢 Socket connected");
      socket!.emit("join", userId);
    });

    // 🔴 NEW MESSAGE (user / support / auto-reply)
    socket!.on("new_message", (data) {
      messages.add(Map<String, dynamic>.from(data));
      notifyListeners();
    });

    // 🧹 REMOVE AUTO-REPLY WHEN ADMIN RESPONDS
    socket!.on("remove_message", (messageId) {
      messages.removeWhere((m) => m["_id"] == messageId);
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

  void disposeSocket() {
    socket?.disconnect();
    socket = null;
  }

  // ===============================
  // LOAD MESSAGES (REST)
  // ===============================
  Future<void> loadMessages(String token) async {
    loading = true;
    notifyListeners();

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/support/my"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        messages = List<Map<String, dynamic>>.from(json.decode(res.body));
      }
    } catch (e) {
      debugPrint("Load support messages error: $e");
    }

    loading = false;
    notifyListeners();
  }

  // ===============================
  // SEND MESSAGE (OPTIMISTIC + RETRY)
  // ===============================
  Future<void> sendMessage(String token, String text) async {
    final tempMessage = {
      "_id": DateTime.now().millisecondsSinceEpoch.toString(),
      "sender": "user",
      "message": text,
      "pending": true,
    };

    messages.add(tempMessage);
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/support/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"message": text}),
      );

      if (res.statusCode == 201) {
        messages.remove(tempMessage);
        messages.addAll(List<Map<String, dynamic>>.from(json.decode(res.body)));
      }
    } catch (e) {
      tempMessage["failed"] = true;
      debugPrint("Send support message error: $e");
    }

    notifyListeners();
  }

  // ===============================
  // TYPING EVENTS
  // ===============================
  void emitTyping() {
    socket?.emit("typing");
  }

  void emitStopTyping() {
    socket?.emit("stop_typing");
  }
}
