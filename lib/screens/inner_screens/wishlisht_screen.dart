// Simplified WishlistScreen with updated provider
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/wishlist_provider.dart';
import 'package:smartshop/screens/productWidget.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/services/my_functions.dart';
import 'package:smartshop/wigets/empty_bag.dart';
import 'package:smartshop/wigets/titletext.dart';

class WishlistScreen extends StatelessWidget {
  static const routName = "/WishListScreen";
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        final wishlistProducts = wishlistProvider.wishlistProducts;

        if (wishlistProducts.isEmpty) {
          return Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.bagWish,
              title: "Nothing in your Wishlist",
              subtitle: "Looks like your wishlist is empty. Add some products to make me happy!",
              buttonText: "Shop now",
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(AssetsManager.shoppingCart),
            ),
            title: TitlesTextWidget(
              label: "Wishlist (${wishlistProducts.length})",
            ),
            actions: [
              IconButton(
                onPressed: () {
                  MyAppFunctions.showErrorOrWarningDialog(
                    isError: false,
                    context: context,
                    fct: () {
                      wishlistProvider.clearLocalWishList();
                    },
                    subtitle: "Clear Wishlist",
                  );
                },
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          body: DynamicHeightGridView(
            itemCount: wishlistProducts.length,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            builder: (ctx, index) {
              final product = wishlistProducts[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProductWidget(
                  product: product,
                  isCompact: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}