import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/constants/styles.dart';
import 'package:smartshop/firebase_options.dart';
import 'package:smartshop/models/product_model.dart';
import 'package:smartshop/providers/product_provider.dart';
import 'package:smartshop/providers/theme_provider.dart';
import 'package:smartshop/providers/user_provider.dart';
import 'package:smartshop/providers/wishlist_provider.dart';
import 'package:smartshop/root_screen.dart';
import 'package:smartshop/screens/admin/admin_dashboard.dart';
import 'package:smartshop/screens/admin/product_form_screen.dart';
import 'package:smartshop/screens/auth/forgot_password.dart';
import 'package:smartshop/screens/auth/login_screen.dart';
import 'package:smartshop/screens/auth/register_screen.dart';
import 'package:smartshop/screens/inner_screens/wishlisht_screen.dart';
import 'package:smartshop/screens/product_detail_screen.dart';
import 'package:smartshop/screens/search_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
       ChangeNotifierProvider(create: (_) => ProductProvider()),
       ChangeNotifierProvider(create: (_) => WishlistProvider()),

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SmartShop',
            debugShowCheckedModeBanner: false,
            theme: Style.themeData(
              isDarktheme: themeProvider.getIsDarkTheme,
              context: context,
            ),
            initialRoute: FirebaseAuth.instance.currentUser == null
                ? LoginScreen.routName
                : RootScreen.routName,
            routes: {
              LoginScreen.routName: (context) => const LoginScreen(),
              RegisterScreen.routName: (context) => const RegisterScreen(),
              RootScreen.routName: (context) => const RootScreen(),
              AdminDashboard.routName: (context) => const AdminDashboard(),
              ProductFormScreen.routName: (context) => const ProductFormScreen(),
              ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
              SearchScreen.routName: (context) => const SearchScreen(), 
              WishlistScreen.routName:(context) => const WishlistScreen()
            },
            onGenerateRoute: (settings) {
              // Handle routes that need arguments
              if (settings.name == ProductDetailScreen.routName) {
                final product = settings.arguments as ProductModel;
                return MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                );
              }
              return null;
            },
          );
        },
      ),
    ),
  );
}