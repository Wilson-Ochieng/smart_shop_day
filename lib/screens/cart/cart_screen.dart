
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/cart_prodiver.dart';
import 'package:smartshop/providers/product_provider.dart';
import 'package:smartshop/providers/user_provider.dart';
import 'package:smartshop/screens/cart/bottom_checkout.dart';
import 'package:smartshop/screens/cart/cart_widget.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/services/my_functions.dart';
import 'package:smartshop/wigets/empty_bag.dart';
import 'package:smartshop/wigets/titletext.dart';
import 'package:uuid/uuid.dart';

class CartScreen extends StatelessWidget {
  static const routName = "/CartScreen";
  const CartScreen({super.key});
  final bool isEmpty = false;

  //condition?true:false
  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    return cartProvider.getCartItems.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.shoppingBasket,
              title: "Your cart is empty",
              subtitle:
                  "Looks like your cart is empty add something and make me happy",
              buttonText: "Shop now",
            ),
          )
        : Scaffold(
            bottomSheet: CartBottomSheetWidget(),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(AssetsManager.shoppingCart),
              ),
              title: TitlesTextWidget(
                label: "Cart is (${cartProvider.getCartItems.length})",
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      fct: () {
                        cartProvider.clearLocalCart();
                      },
                      subtitle: "Clear Cart",
                    );
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.getCartItems.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider.value(
                        value: cartProvider.getCartItems.values.toList()[index],

                        child: const CartWidget(),
                      );
                    },
                  ),
                ),
                SizedBox(height: kBottomNavigationBarHeight + 10),
              ],
            ),
          );
  }

  Future<void> placeOrderAdvanced({
    required CartProvider cartProvider,
    required ProductProvider productsProvider,
    required UserProvider userProvider,
    required BuildContext context,
  }) async {
    try {
      final user = userProvider.getUser;
      final orderId = const Uuid().v4();

      final products = cartProvider.getCartItems.values.map((cartItem) {
        final product = productsProvider.findByProdId(cartItem.productId);
        return {
          'productId': cartItem.productId,
          'title': product?.name,
          'price': product?.price,
          'quantity': cartItem.quantity,
          'image': product?.imageUrl,
        };
      }).toList();

      final total = cartProvider.getTotal(productsProvider: productsProvider);

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': user!.uid,
        'products': products,
        'totalAmount': total,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      cartProvider.clearLocalCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
    }
  }
}
