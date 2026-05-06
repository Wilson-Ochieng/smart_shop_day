import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/services/cloudinary_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchProducts() async {
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
    } catch (e) {
      debugPrint('Error fetching products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

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
      // 1. Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(imageFile);
      if (imageUrl == null) return 'Image upload failed';

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
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int stock,
    File? newImageFile,       // null means keep existing image
    required String existingImageUrl,
  }) async {
    try {
      String imageUrl = existingImageUrl;

      // Upload new image only if one was selected
      if (newImageFile != null) {
        final uploaded = await CloudinaryService.uploadImage(newImageFile);
        if (uploaded == null) return 'Image upload failed';
        imageUrl = uploaded;
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
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}