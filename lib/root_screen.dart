import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/cart_prodiver.dart';
import 'package:smartshop/screens/cart/cart_screen.dart';
import 'package:smartshop/screens/home_screen.dart';
import 'package:smartshop/screens/profile_screen.dart';
import 'package:smartshop/screens/search_screen.dart';

class RootScreen extends StatefulWidget {
  static const routName = "/RootScreen";

  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late List<Widget> screens;
  int currentScreen = 0;
  late PageController controller;
  @override
  void initState() {
    screens = const [
      HomeScreen(),
      SearchScreen(),
      CartScreen(),
      ProfileScreen(),
    ];

    controller = PageController(initialPage: currentScreen);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: screens,
      ),

      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, CartProvider, child) {
          final cartItemCount = CartProvider.getCartItems.length;

          return NavigationBar(
            selectedIndex: currentScreen,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            height: kBottomNavigationBarHeight,
            onDestinationSelected: (index) {
              setState(() {
                currentScreen = index;
              });
              controller.jumpToPage(currentScreen);
            },

            destinations: [
              NavigationDestination(
                selectedIcon: Icon(IconlyBold.activity),
                icon: Icon(IconlyLight.home),
                label: 'Home',
              ),
              NavigationDestination(
                selectedIcon: Icon(IconlyBold.search),
                icon: Icon(IconlyLight.search),
                label: 'Search',
              ),
              // NavigationDestination(
              //   selectedIcon: Icon(IconlyBold.bag_2),
              //   icon: Icon(IconlyLight.bag_2),
              //   label: 'Cart',
              // ),
              NavigationDestination(
                selectedIcon: Icon(IconlyBold.bag2),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(IconlyLight.bag2),
                    if (cartItemCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartItemCount > 99
                                ? '99+'
                                : cartItemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              NavigationDestination(
                selectedIcon: Icon(IconlyBold.profile),
                icon: Icon(IconlyLight.profile),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
