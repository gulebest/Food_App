class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double rating;
  final String calories;
  final String category; // ⭐ NEW FIELD

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.calories,
    required this.category,
  });
}
