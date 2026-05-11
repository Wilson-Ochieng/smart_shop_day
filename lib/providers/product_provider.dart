import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/services/cloudinary_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  final _firestore = FirebaseFirestore.instance;

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
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}