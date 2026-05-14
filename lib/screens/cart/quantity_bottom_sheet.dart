import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/models/cart_model.dart';
import 'package:smartshop/providers/cart_prodiver.dart';
import 'package:smartshop/wigets/sub_titletext%20.dart';

class QuantityBottomSheetWidget extends StatelessWidget {
  const QuantityBottomSheetWidget({super.key, required this.cartModel});
  final CartModel cartModel;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currentQuantity = cartModel.quantity;
    final maxQuantity = 25; // You can make this dynamic based on stock

    return Column(
      children: [
        const SizedBox(height: 20),
        // Drag handle
        Container(
          height: 6,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Select Quantity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Current quantity indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Quantity:',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  '$currentQuantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Quantity list
        Expanded(
          child: ListView.builder(
            itemCount: maxQuantity,
            itemBuilder: (context, index) {
              final quantity = index + 1;
              final isSelected = quantity == currentQuantity;
              
              return InkWell(
                onTap: () {
                  cartProvider.updateQty(
                    productId: cartModel.productId,
                    qty: quantity,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: Colors.blue, width: 1)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        quantity.toString(), // Convert to String
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}