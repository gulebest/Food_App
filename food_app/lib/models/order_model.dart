class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderItem {
  final Map<String, dynamic> product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: json['product'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
