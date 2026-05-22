// Updated heart_button_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/providers/wishlist_provider.dart';

class HeartButtonWidget extends StatelessWidget {
  const HeartButtonWidget({
    super.key,
    this.bkgColor = Colors.transparent,
    this.size = 20,
    required this.product, // Now accepts ProductModel
  });
  
  final Color bkgColor;
  final double size;
  final ProductModel product; // Changed from String productId

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Container(
      decoration: BoxDecoration(color: bkgColor, shape: BoxShape.circle),
      child: IconButton(
        style: IconButton.styleFrom(elevation: 10),
        onPressed: () {
          wishlistProvider.addOrRemoveFromWishList(product: product);
        },
        icon: Icon(
          wishlistProvider.isProdinWishList(productId: product.id)
              ? IconlyBold.heart
              : IconlyLight.heart,
          size: size,
          color: wishlistProvider.isProdinWishList(productId: product.id)
              ? Colors.red
              : Colors.grey,
        ),
      ),
    );
  }
}