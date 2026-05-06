class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final String createdBy;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    required this.createdBy,
  });

  factory ProductModel.fromDocument(String id, Map<String, dynamic> doc) {
    return ProductModel(
      id: id,
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      imageUrl: doc['imageUrl'] ?? '',
      category: doc['category'] ?? '',
      stock: doc['stock'] ?? 0,
      createdBy: doc['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'createdBy': createdBy,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}