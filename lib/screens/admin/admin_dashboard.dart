import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartshop/screens/admin/products_screen.dart';
import 'package:smartshop/screens/admin/user_screen.dart';
import 'package:smartshop/screens/auth/login_screen.dart';
import 'package:smartshop/services/my_functions.dart';

class AdminDashboard extends StatelessWidget {
  static const routName = "/AdminDashboard";

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),

                icon: Icon(
                  user == null ? Icons.login : Icons.logout,
                ),

                label: Text(
                  user == null ? "Login" : "Logout",
                ),

                onPressed: () async {
                  if (user == null) {
                    Navigator.pushNamed(
                      context,
                      LoginScreen.routName,
                    );
                  } else {
                    await MyAppFunctions.showErrorOrWarningDialog(
                      context: context,
                      subtitle:
                          "Are you sure you want to Sign Out?",

                      fct: () async {
                        await FirebaseAuth.instance.signOut();

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

          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.inventory_2),
                text: 'Products',
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Users',
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            ProductsScreen(),
            UsersScreen(),
          ],
        ),
      ),
    );
  }
}