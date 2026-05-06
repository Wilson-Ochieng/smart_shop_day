class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? icon;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final bool isActive;
  final int productCount;
  
  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.icon,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.isActive = true,
    this.productCount = 0,
  });
  
  // Convert to Map for Firebase/Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'isActive': isActive,
      'productCount': productCount,
    };
  }
  
  // Create from Map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      icon: map['icon'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
      createdBy: map['createdBy'] ?? '',
      isActive: map['isActive'] ?? true,
      productCount: map['productCount'] ?? 0,
    );
  }
  
  // Copy with updates
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
    int? productCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
    );
  }
}