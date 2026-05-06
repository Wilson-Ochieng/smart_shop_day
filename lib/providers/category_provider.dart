// providers/category_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get activeCategories => 
      _categories.where((c) => c.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load categories from Firestore
  Future<void> loadCategories() async {
    setLoading(true);
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();
      
      _categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
      
      // Update product counts for each category
      await _updateProductCounts();
      
      setError(null);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
  
  // Add new category
  Future<String?> addCategory({
    required String name,
    String? description,
    String? imageUrl,
    String? icon,
    required String createdBy,
  }) async {
    setLoading(true);
    try {
      // Check for duplicate
      final existing = _categories.any((c) => 
          c.name.toLowerCase() == name.toLowerCase());
      if (existing) {
        return 'Category already exists';
      }
      
      final newCategory = CategoryModel(
        id: _firestore.collection('categories').doc().id,
        name: name,
        description: description,
        imageUrl: imageUrl,
        icon: icon,
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );
      
      await _firestore
          .collection('categories')
          .doc(newCategory.id)
          .set(newCategory.toMap());
      
      _categories.add(newCategory);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      setLoading(false);
    }
  }
  
  // Update category
  Future<String?> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? imageUrl,
    String? icon,
    bool? isActive,
  }) async {
    setLoading(true);
    try {
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index == -1) return 'Category not found';
      
      final updatedCategory = _categories[index].copyWith(
        name: name,
        description: description,
        imageUrl: imageUrl,
        icon: icon,
        updatedAt: DateTime.now(),
        isActive: isActive,
      );
      
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update(updatedCategory.toMap());
      
      _categories[index] = updatedCategory;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      setLoading(false);
    }
  }
  
  // Delete category (soft delete)
  Future<String?> deleteCategory(String categoryId) async {
    setLoading(true);
    try {
      // Check if category has products
      final productCount = await _getProductCountForCategory(categoryId);
      if (productCount! > 0) {
        return 'Cannot delete category with $productCount product(s). Reassign products first.';
      }
      
      // Soft delete
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({'isActive': false});
      
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      setLoading(false);
    }
  }
  
  // Hard delete (only for empty categories)
  Future<String?> hardDeleteCategory(String categoryId) async {
    setLoading(true);
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      setLoading(false);
    }
  }
  
  // Helper methods
  Future<int?> _getProductCountForCategory(String categoryId) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    
    return querySnapshot.count;
  }
  
  Future<void> _updateProductCounts() async {
    for (var i = 0; i < _categories.length; i++) {
      final count = await _getProductCountForCategory(_categories[i].id);
      if (_categories[i].productCount != count) {
        _categories[i] = _categories[i].copyWith(productCount: count);
      }
    }
    notifyListeners();
  }
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}