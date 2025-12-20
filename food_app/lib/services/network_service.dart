import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkService() {
    _init();
  }

  Future<void> _init() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _updateStatus(results);

      _subscription = Connectivity().onConnectivityChanged.listen(
        _updateStatus,
      );
    } catch (e) {
      // 🔒 Absolute safety: never crash app startup
      _isOnline = false;
      notifyListeners();
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // ✅ SAFE
    super.dispose();
  }
}
