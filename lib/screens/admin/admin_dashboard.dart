import 'package:flutter/material.dart';
import 'package:smartshop/screens/admin/products_screen.dart';
import 'package:smartshop/screens/admin/user_screen.dart';

class AdminDashboard extends StatelessWidget {
  static const routName = "/AdminDashboard";

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2), text: 'Products'),
              Tab(icon: Icon(Icons.people), text: 'Users'),
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