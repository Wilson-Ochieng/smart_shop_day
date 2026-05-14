
import 'package:flutter/material.dart';
import 'package:smartshop/models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final Map<String, ProductModel> _wishListItems = {};
  
  Map<String, ProductModel> get getWishlists {
    return _wishListItems;
  }
  
  List<ProductModel> get wishlistProducts {
    return _wishListItems.values.toList();
  }

  void addOrRemoveFromWishList({required ProductModel product}) {
    if (_wishListItems.containsKey(product.id)) {
      _wishListItems.remove(product.id);
    } else {
      _wishListItems.putIfAbsent(
        product.id,
        () => product,
      );
    }
    notifyListeners();
  }

  bool isProdinWishList({required String productId}) {
    return _wishListItems.containsKey(productId);
  }

  void clearLocalWishList() {
    _wishListItems.clear();
    notifyListeners();
  }
}