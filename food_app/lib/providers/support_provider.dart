import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:connectivity_plus/connectivity_plus.dart';

class SupportProvider extends ChangeNotifier {
  final String baseUrl = "https://foodapp-backend-796q.onrender.com";

  List<Map<String, dynamic>> messages = [];
  bool loading = false;
  bool isTyping = false;

  IO.Socket? socket;
  final Connectivity _connectivity = Connectivity();
  bool _online = true;

  static const _storageKey = "support_messages";

  SupportProvider() {
    _connectivity.onConnectivityChanged.listen(_onConnectivityChange);
  }

  // ===============================
  // CONNECTIVITY (FIXED)
  // ===============================
  void _onConnectivityChange(List<ConnectivityResult> results) {
    final isNowOnline =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (!_online && isNowOnline) {
      _retryPendingMessages();
    }

    _online = isNowOnline;
  }

  // ===============================
  // LOCAL STORAGE
  // ===============================
  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(messages));
  }

  Future<void> loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      messages = List<Map<String, dynamic>>.from(json.decode(raw));
      notifyListeners();
    }
  }

  // ===============================
  // SOCKET
  // ===============================
  void initSocket(String userId) {
    if (socket != null) return;

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      socket!.emit("join", userId);
    });

    socket!.on("new_message", (data) {
      final incoming = Map<String, dynamic>.from(data);

      final exists = messages.any((m) => m["_id"] == incoming["_id"]);
      if (exists) return;

      incoming["status"] = "sent";
      messages.add(incoming);
      _saveLocal();
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
  // LOAD MESSAGES
  // ===============================
  Future<void> loadMessages(String token) async {
    loading = true;
    notifyListeners();

    await loadLocal();

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/api/support/my"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        messages = List<Map<String, dynamic>>.from(json.decode(res.body)).map((
          m,
        ) {
          m["status"] ??= "sent";
          return m;
        }).toList();

        _saveLocal();
      }
    } catch (_) {}

    loading = false;
    notifyListeners();
  }

  // ===============================
  // SEND MESSAGE (OFFLINE SAFE)
  // ===============================
  Future<void> sendMessage(String token, String text) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final tempMessage = {
      "_id": tempId,
      "sender": "user",
      "message": text,
      "status": "sending",
      "createdAt": DateTime.now().toIso8601String(),
    };

    messages.add(tempMessage);
    _saveLocal();
    notifyListeners();

    if (!_online) return;

    await _sendToServer(token, tempMessage);
  }

  Future<void> retryMessage(String token, Map<String, dynamic> message) async {
    message["status"] = "sending";
    notifyListeners();
    await _sendToServer(token, message);
  }

  Future<void> _sendToServer(String token, Map<String, dynamic> message) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/support/send"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"message": message["message"]}),
      );

      if (res.statusCode == 201) {
        messages.removeWhere((m) => m["_id"] == message["_id"]);
        messages.addAll(List<Map<String, dynamic>>.from(json.decode(res.body)));
        _saveLocal();
      } else {
        message["status"] = "failed";
      }
    } catch (_) {
      message["status"] = "failed";
    }

    _saveLocal();
    notifyListeners();
  }

  // ===============================
  // RETRY QUEUE
  // ===============================
  Future<void> _retryPendingMessages() async {
    final token = await _loadToken();
    if (token == null) return;

    for (final msg in messages.where(
      (m) => m["status"] == "sending" || m["status"] == "failed",
    )) {
      await _sendToServer(token, msg);
    }
  }

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ===============================
  // TYPING
  // ===============================
  void emitTyping(String targetId) => socket?.emit("typing", targetId);

  void emitStopTyping(String targetId) => socket?.emit("stop_typing", targetId);
}
