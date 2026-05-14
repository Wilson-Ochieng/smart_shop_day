import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/wigets/empty_bag.dart';
import 'package:smartshop/wigets/titletext.dart';


class OrderScreen extends StatelessWidget {
  static const routeName = '/OrderScreen';

  const OrderScreen({super.key, required Map<String, dynamic> orderData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: 'Placed Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyBagWidget(
              imagePath: AssetsManager.orderBag,
              title: "No orders placed yet",
              subtitle: "Start shopping to place your first order!",
              buttonText: "Shop now",
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.separated(
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                child: OrderScreen(orderData: orderData),
              );
            },
            separatorBuilder: (ctx, index) => const Divider(),
          );
        },
      ),
    );
  }
}
