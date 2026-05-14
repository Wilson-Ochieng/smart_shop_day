import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/models/cart_model.dart';
import 'package:smartshop/providers/cart_prodiver.dart';
import 'package:smartshop/providers/product_provider.dart';
import 'package:smartshop/screens/cart/quantity_bottom_sheet.dart';
import 'package:smartshop/wigets/heart_btn.dart';
import 'package:smartshop/wigets/sub_titletext%20.dart';
import 'package:smartshop/wigets/titletext.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  /// Kenyan Shilling formatter - handles both double and String prices
  String _formatPrice(dynamic price) {
    double parsedPrice = 0.0;
    
    if (price is double) {
      parsedPrice = price;
    } else if (price is int) {
      parsedPrice = price.toDouble();
    } else if (price is String) {
      parsedPrice = double.tryParse(price) ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }
    
    final formatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KES ',
      decimalDigits: 0,
    );
    return formatter.format(parsedPrice);
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final productsProvider = Provider.of<ProductProvider>(context);
    final getCurrentProduct = productsProvider.findByProdId(cartModel.productId);
    final cartProvider = Provider.of<CartProvider>(context);

    Size size = MediaQuery.of(context).size;
    
    if (getCurrentProduct == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FancyShimmerImage(
              imageUrl: getCurrentProduct.imageUrl,
              height: size.height * 0.12,
              width: size.height * 0.12,
              boxFit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          /// Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TitlesTextWidget(
                        label: getCurrentProduct.name,
                        maxLines: 2,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            cartProvider.removeOneItem(
                              productId: getCurrentProduct.id,
                            );
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        HeartButtonWidget(
                          product: getCurrentProduct,
                          bkgColor: Colors.transparent,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                /// Category
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getCurrentProduct.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                /// Price and Quantity row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SubTitletext(
                      label: _formatPrice(getCurrentProduct.price),
                      color: Colors.green.shade700,
                    
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await showModalBottomSheet(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          context: context,
                          builder: (context) {
                            return QuantityBottomSheetWidget(
                              cartModel: cartModel,
                            );
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Row(
                        children: [
                          const Icon(IconlyLight.arrow_down_2, size: 16),
                          const SizedBox(width: 4),
                          Text("Qty: ${cartModel.quantity}"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                /// Stock info
                Row(
                  children: [
                    Icon(Icons.inventory, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${getCurrentProduct.stock}',
                      style: TextStyle(
                        fontSize: 10,
                        color: getCurrentProduct.stock > 0 
                            ? Colors.green.shade700 
                            : Colors.red,
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
}