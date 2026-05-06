import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartshop/constants/styles.dart';
import 'package:smartshop/firebase_options.dart';
import 'package:smartshop/providers/category_provider.dart';
import 'package:smartshop/providers/product_provider.dart';
import 'package:smartshop/providers/theme_provider.dart';
import 'package:smartshop/providers/user_provider.dart';
import 'package:smartshop/root_screen.dart';
import 'package:smartshop/screens/admin/admin_dashboard.dart';
import 'package:smartshop/screens/admin/product_form_screen.dart';
import 'package:smartshop/screens/auth/forgot_password.dart';
import 'package:smartshop/screens/auth/login_screen.dart';
import 'package:smartshop/screens/auth/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return UserProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider()),

        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
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
              ProductFormScreen.routName: (context) =>
                  const ProductFormScreen(),
              ForgotPasswordScreen.routeName: (context) =>
                  const ForgotPasswordScreen(),
            },
            // home: LoginScreen(),
          );
        },
      ),
    ),
  );
}
