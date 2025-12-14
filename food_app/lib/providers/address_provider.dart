import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/api_service.dart';

class AddressProvider with ChangeNotifier {
  bool isLoading = false;
  List<AddressModel> addresses = [];
  AddressModel? selectedAddress;

  // ======================
  // FETCH ADDRESSES
  // ======================
  Future<void> fetchAddresses() async {
    isLoading = true;
    notifyListeners();

    final data = await ApiService.getAddresses();
    addresses = data.map((e) => AddressModel.fromJson(e)).toList();

    // auto select default
    if (addresses.isNotEmpty) {
      selectedAddress = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses[0],
      );
    }

    isLoading = false;
    notifyListeners();
  }

  // ======================
  // ADD ADDRESS
  // ======================
  Future<bool> addAddress(Map<String, dynamic> payload) async {
    isLoading = true;
    notifyListeners();

    final result = await ApiService.addAddress(payload);

    if (result != null) {
      addresses.insert(0, AddressModel.fromJson(result));
      selectedAddress = addresses.first;
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // ======================
  // SELECT ADDRESS
  // ======================
  void selectAddress(AddressModel address) {
    selectedAddress = address;
    notifyListeners();
  }
}
