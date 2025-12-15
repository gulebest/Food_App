class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final double rating;
  final String calories;
  final String category;

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'].toString(), // ✅ MongoDB ObjectId
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      calories: json['calories'] ?? '',
      category: json['category'] ?? 'Classics',
    );
  }
}
