class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String country;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.country,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      label: json['label'],
      fullName: json['fullName'],
      phone: json['phone'],
      street: json['street'],
      city: json['city'],
      country: json['country'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}
