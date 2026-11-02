class GreenProduct {
  final String name;
  final String category;
  final String description;
  final double price;
  final String imageUrl;

  GreenProduct({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory GreenProduct.fromJson(Map<String, dynamic> json) {
    return GreenProduct(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  String get formattedPrice => 'Rs. ${price.toStringAsFixed(0)}';
}