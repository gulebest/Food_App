import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/address_provider.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final label = TextEditingController();
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final country = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Address")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(label, "Label (Home / Work)"),
              _field(fullName, "Full Name"),
              _field(phone, "Phone"),
              _field(street, "Street"),
              _field(city, "City"),
              _field(country, "Country"),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await Provider.of<AddressProvider>(
                    context,
                    listen: false,
                  ).addAddress({
                    "label": label.text,
                    "fullName": fullName.text,
                    "phone": phone.text,
                    "street": street.text,
                    "city": city.text,
                    "country": country.text,
                    "isDefault": false,
                  });

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Save Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
