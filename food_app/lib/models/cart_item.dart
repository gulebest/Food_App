class CartItem {
  final String productId; // MongoDB _id
  final String name;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
  });
}
