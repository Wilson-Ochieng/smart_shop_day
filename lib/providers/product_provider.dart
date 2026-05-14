import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/services/cloudinary_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Track unique categories for filtering
  List<String> _categories = [];
  
  List<ProductModel> get getProducts => _products;
  bool get isLoading => _isLoading;
  List<ProductModel> get products => _products;
  
  // Get unique categories from products
  List<String> get categories {
    _updateCategories();
    return _categories;
  }

  // Get category count for each category
  Map<String, int> get categoryCount {
    final Map<String, int> count = {};
    for (final product in _products) {
      count[product.category] = (count[product.category] ?? 0) + 1;
    }
    return count;
  }

  // Update categories list from current products
  void _updateCategories() {
    final uniqueCategories = <String>{};
    for (final product in _products) {
      uniqueCategories.add(product.category);
    }
    _categories = uniqueCategories.toList()..sort();
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // Skip if already loading
    if (_isLoading) return;
    
    // Skip if already have products and not forcing refresh
    if (_products.isNotEmpty && !forceRefresh) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs
          .map((doc) => ProductModel.fromDocument(doc.id, doc.data()))
          .toList();
      
      _updateCategories();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mobile: Add product with File
  Future<String?> addProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    required File imageFile,
    required String createdBy,
  }) async {
    try {
      debugPrint('Adding product (mobile)...');
      
      // 1. Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(imageFile);
      if (imageUrl == null) return 'Image upload failed';
      
      debugPrint('Image uploaded successfully: $imageUrl');

      // 2. Save product data to Firestore
      final docRef = await _firestore.collection('products').add(
        ProductModel(
          id: '',
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          stock: stock,
          createdBy: createdBy,
        ).toMap(),
      );

      // 3. Add to local list
      _products.insert(
        0,
        ProductModel(
          id: docRef.id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          stock: stock,
          createdBy: createdBy,
        ),
      );
      
      _updateCategories();
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error adding product: $e');
      return e.toString();
    }
  }

  // Web: Add product with XFile
  Future<String?> addProductWeb({
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    required XFile imageFile,
    required String createdBy,
  }) async {
    try {
      debugPrint('Adding product (web)...');
      
      // 1. Upload image to Cloudinary from web
      final imageUrl = await CloudinaryService.uploadImageWeb(imageFile);
      if (imageUrl == null) return 'Image upload failed';
      
      debugPrint('Image uploaded successfully: $imageUrl');

      // 2. Save product data to Firestore
      final docRef = await _firestore.collection('products').add(
        ProductModel(
          id: '',
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          stock: stock,
          createdBy: createdBy,
        ).toMap(),
      );

      // 3. Add to local list
      _products.insert(
        0,
        ProductModel(
          id: docRef.id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          stock: stock,
          createdBy: createdBy,
        ),
      );
      
      _updateCategories();
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error adding product (web): $e');
      return e.toString();
    }
  }

  // Mobile: Update product with File
  Future<String?> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    File? newImageFile,
    required String existingImageUrl,
  }) async {
    try {
      debugPrint('Updating product (mobile): $productId');
      
      String imageUrl = existingImageUrl;

      // Upload new image only if one was selected
      if (newImageFile != null) {
        debugPrint('Uploading new image...');
        final uploaded = await CloudinaryService.uploadImage(newImageFile);
        if (uploaded == null) return 'Image upload failed';
        imageUrl = uploaded;
        debugPrint('New image uploaded: $imageUrl');
      }

      final updatedData = {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'stock': stock,
      };

      await _firestore
          .collection('products')
          .doc(productId)
          .update(updatedData);

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = ProductModel(
          id: productId,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          stock: stock,
          createdBy: _products[index].createdBy,
        );
        
        _updateCategories();
        notifyListeners();
      }
      return null;
    } catch (e) {
      debugPrint('Error updating product: $e');
      return e.toString();
    }
  }

  // Web: Update product with XFile
  Future<String?> updateProductWeb({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    required XFile newImageFile,
    required String existingImageUrl,
  }) async {
    try {
      debugPrint('Updating product (web): $productId');
      
      // Upload new image to Cloudinary from web
      debugPrint('Uploading new image...');
      final imageUrl = await CloudinaryService.uploadImageWeb(newImageFile);
      if (imageUrl == null) return 'Image upload failed';
      
      debugPrint('New image uploaded: $imageUrl');

      final updatedData = {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'stock': stock,
      };

      await _firestore
          .collection('products')
          .doc(productId)
          .update(updatedData);

      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = ProductModel(
          id: productId,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          category: category,
          stock: stock,
          createdBy: _products[index].createdBy,
        );
        
        _updateCategories();
        notifyListeners();
      }
      return null;
    } catch (e) {
      debugPrint('Error updating product (web): $e');
      return e.toString();
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      
      _updateCategories();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Find product by ID
  ProductModel? findByProdId(String productId) {
    try {
      return _products.firstWhere((element) => element.id == productId);
    } catch (_) {
      return null;
    }
  }

  // Find products by category (case-insensitive)
  List<ProductModel> findByCategory({required String categoryName}) {
    if (categoryName == "All") {
      return _products;
    }
    return _products
        .where(
          (element) => element.category.toLowerCase().contains(
            categoryName.toLowerCase(),
          ),
        )
        .toList();
  }

  // Get products by exact category match
  List<ProductModel> getProductsByCategory({required String category}) {
    return _products.where((product) => product.category == category).toList();
  }

  // Search products by name or description
  List<ProductModel> searchProducts({required String searchText}) {
    if (searchText.isEmpty) return _products;
    
    return _products.where((product) {
      return product.name.toLowerCase().contains(searchText.toLowerCase()) ||
          product.description.toLowerCase().contains(searchText.toLowerCase()) ||
          product.category.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  // Search within a specific list (for filtering)
  List<ProductModel> searchQuery({
    required String searchText,
    required List<ProductModel> passedList,
  }) {
    if (searchText.isEmpty) return passedList;
    
    return passedList
        .where(
          (element) => element.name.toLowerCase().contains(
            searchText.toLowerCase(),
          ),
        )
        .toList();
  }

  // Get featured products (e.g., first 6 products or by some criteria)
  List<ProductModel> getFeaturedProducts({int limit = 6}) {
    return _products.take(limit).toList();
  }

  // Get products by price range
  List<ProductModel> getProductsByPriceRange({
    required double minPrice,
    required double maxPrice,
  }) {
    return _products.where((product) {
      return product.price >= minPrice && product.price <= maxPrice;
    }).toList();
  }

  // Get products with low stock (for admin alerts)
  List<ProductModel> getLowStockProducts({int threshold = 5}) {
    return _products.where((product) => product.stock <= threshold).toList();
  }

  // Get products count by category
  int getProductCountByCategory(String category) {
    return _products.where((product) => product.category == category).length;
  }

  // Get all unique categories with product counts
  Map<String, int> getCategoriesWithCount() {
    final Map<String, int> categoryMap = {};
    for (final product in _products) {
      categoryMap[product.category] = (categoryMap[product.category] ?? 0) + 1;
    }
    return categoryMap;
  }

  // Clear all products (useful for logout)
  void clearProducts() {
    _products.clear();
    _categories.clear();
    notifyListeners();
  }
}