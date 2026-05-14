// product_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:smartshop/providers/cart_prodiver.dart';
import 'package:smartshop/wigets/heart_btn.dart';

// Reusable Product Widget
class ProductWidget extends StatelessWidget {
  final ProductModel product;
  final bool isCompact;
  final VoidCallback? onTap;
  final double imageHeight;
  final double? imageWidth;
  final BoxFit imageFit;

  const ProductWidget({
    super.key,
    required this.product,
    this.isCompact = false,
    this.onTap,
    this.imageHeight = 120,
    this.imageWidth,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showProductDialog(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isCompact
            ? _buildCompactLayout(context)
            : _buildFullLayout(context),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.isProdinCart(productId: product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image with heart button overlay
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: FancyShimmerImage(
                imageUrl: product.imageUrl,
                height: imageHeight,
                width: imageWidth ?? double.infinity,
                boxFit: imageFit,
                errorWidget: Container(
                  height: imageHeight,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
            // Heart button overlay
            Positioned(
              top: 8,
              right: 8,
              child: HeartButtonWidget(
                product: product,
                bkgColor: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ),
          ],
        ),

        // Product details
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KES ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                  // Add to Cart Button (Compact)
                  Material(
                    borderRadius: BorderRadius.circular(20),
                    color: isInCart ? Colors.green : Colors.blue,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _addToCart(context, cartProvider);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isInCart ? Icons.check : Icons.shopping_cart,
                              color: Colors.white,
                              size: 16,
                            ),
                            if (!isInCart) ...[
                              const SizedBox(width: 4),
                              const Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.inventory, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isInCart = cartProvider.isProdinCart(productId: product.id);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FancyShimmerImage(
                  imageUrl: product.imageUrl,
                  height: 100,
                  width: 100,
                  boxFit: BoxFit.cover,
                  errorWidget: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              // Heart button overlay
              Positioned(
                top: 4,
                right: 4,
                child: HeartButtonWidget(
                  product: product,
                  bkgColor: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'KES ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                    // Add to Cart Button
                    Material(
                      borderRadius: BorderRadius.circular(25),
                      color: isInCart ? Colors.green : Colors.blue,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          _addToCart(context, cartProvider);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isInCart ? Icons.check : Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.inventory,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to add product to cart with feedback
  void _addToCart(BuildContext context, CartProvider cartProvider) {
    // Check if product is already in cart
    if (cartProvider.isProdinCart(productId: product.id)) {
      // Show message that product is already in cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is already in your cart'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if product is in stock
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product is out of stock'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add to cart
    cartProvider.addProductToCart(productId: product.id);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showProductDialog(BuildContext context, ProductModel product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isInCart = cartProvider.isProdinCart(productId: product.id);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with heart button in dialog
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: FancyShimmerImage(
                    imageUrl: product.imageUrl,
                    height: 200,
                    width: double.infinity,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KES ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        
                      ),
                        HeartButtonWidget(
                                  product: product,
                                  bkgColor: Colors.white.withOpacity(0.9),
                                  size: 24,
                                ),
                      // Add to Cart Button in Dialog
                      Material(
                        borderRadius: BorderRadius.circular(30),
                        color: isInCart
                            ? Colors.green
                            : Theme.of(dialogContext).primaryColor,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _addToCart(context, cartProvider);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              
                                Icon(
                                  isInCart ? Icons.check : Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isInCart ? 'In Cart' : 'Add to Cart',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stock Available: ${product.stock}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
