import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/providers/theme_provider.dart';
import 'package:smartshop/providers/user_provider.dart';
import 'package:smartshop/screens/auth/login_screen.dart';
import 'package:smartshop/screens/inner_screens/wishlisht_screen.dart';
import 'package:smartshop/screens/orders/orders_screen.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/services/my_functions.dart';
import 'package:smartshop/wigets/sub_titletext%20.dart';
import 'package:smartshop/wigets/titletext.dart';

class ProfileScreen extends StatefulWidget {
  static const routName = "/ProfileScreen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;

    return Scaffold(
      appBar: AppBar(leading: Image.asset(AssetsManager.shoppingBasket)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Visibility(
            visible: false,
            child: Padding(
              padding: EdgeInsets.all(18.0),
              child: TitlesTextWidget(
                label: "Please login to have unlimited access",
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                           "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlesTextWidget(label: user?.username ?? "Guest"),
                        const SizedBox(height: 6),
                        SubTitletext(label: user?.email ?? ""),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SizedBox(

        
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                  const TitlesTextWidget(label: "General"),
                  const SizedBox(height: 10),
                  CustomListTile(
                    text: "All Orders",
                    imagePath: AssetsManager.orderSvg,
                    function: () {
                         Navigator.pushNamed(context,OrderScreen.routeName);
                    },
                  ),
                  CustomListTile(
                    text: "Wishlist",
                    imagePath: AssetsManager.wishlistSvg,
                    function: () {
                      Navigator.pushNamed(context, WishlistScreen.routName);
                    },
                  ),
                  CustomListTile(
                    text: "Viewed recently",
                    imagePath: AssetsManager.recent,
                    function: () {
                    },
                  ),
                  CustomListTile(
                    text: "Address",
                    imagePath: AssetsManager.address,
                    function: () {
                  
                    },
                  ),
                  const SizedBox(height: 6),
                  const Divider(thickness: 1),
                  const SizedBox(height: 6),
                  const TitlesTextWidget(label: "Settings"),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: Text(
                      themeProvider.getIsDarkTheme ? "Dark Theme" : "Light Theme",
                    ),
                    value: themeProvider.getIsDarkTheme,
                    onChanged: (value) {
                      themeProvider.setDarkTheme(value);
                      print('Theme State , ${themeProvider.getIsDarkTheme}');
                    },
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),

              //Ternary Operator
              //   condition?true:false
              icon: Icon(user == null ? Icons.login : Icons.logout),
              label: Text(user == null ? "Login" : "Logout"),
              onPressed: () async {
                if (user == null) {
                  Navigator.pushNamed(context, LoginScreen.routName);
                } else {
                  await MyAppFunctions.showErrorOrWarningDialog(
                    context: context,
                    subtitle: "Are you sure you want to SignOut",
                    fct: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You have been Signed Out Successfully',
                          ),
                        ),
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        LoginScreen.routName,
                      );
                    },
                    isError: false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.imagePath,
    required this.text,
    required this.function,
  });
  final String imagePath, text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        function();
      },
      title: SubTitletext(label: text),
      leading: Image.asset(imagePath, height: 34),
      trailing: const Icon(IconlyLight.arrow_right_2),
    );
  }
}
