import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartshop/screens/orders/order_status_screen.dart';
import 'package:smartshop/services/app_manager.dart';
import 'package:smartshop/wigets/empty_bag.dart';
import 'package:smartshop/wigets/titletext.dart';
import 'package:smartshop/models/orders_model.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/OrderScreen';

  const OrderScreen({super.key});

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

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderScreen()),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
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
            separatorBuilder: (ctx, index) => const Divider(),
            itemBuilder: (ctx, index) {
              final orderDoc = orders[index];
              final orderData = orderDoc.data() as Map<String, dynamic>;
              
              // Create OrderModel from document
              final order = OrderModel.fromDocument(orderDoc);
              
              // Use OrderCard widget instead of recursive call
              return OrderCard(order: order, orderData: orderData);
            },
          );
        },
      ),
    );
  }
}

// Separate widget for each order card
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Map<String, dynamic> orderData;

  const OrderCard({
    super.key,
    required this.order,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = order.mpesaStatus == 'paid';
    final isCancelled = order.status == 'cancelled';
    final isPending = order.mpesaStatus == 'pending' || order.mpesaStatus == 'stk_push_initiated';
    
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isPaid ? Colors.green.shade100 : 
                   isCancelled ? Colors.red.shade100 : 
                   Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPaid ? Icons.check_circle : 
            isCancelled ? Icons.cancel : 
            Icons.pending,
            color: isPaid ? Colors.green : 
                   isCancelled ? Colors.red : 
                   Colors.orange,
          ),
        ),
        title: Text(
          'Order #${order.orderId.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(order.createdAt)}'),
            const SizedBox(height: 4),
            Text(
              'Status: ${order.mpesaStatus.toUpperCase()}',
              style: TextStyle(
                color: isPaid ? Colors.green : 
                       isCancelled ? Colors.red : 
                       Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Text(
          'KES ${order.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isPaid ? Colors.green : Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Details
                const Text(
                  'Order Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                
                // Products List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.products.length,
                  itemBuilder: (ctx, idx) {
                    final product = order.products[idx];
                    return ListTile(
                      leading: product['image'] != null
                          ? Image.network(
                              product['image'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => 
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.shopping_bag),
                      title: Text(product['title'] ?? 'Unknown Product'),
                      subtitle: Text('Quantity: ${product['quantity']}'),
                      trailing: Text(
                        'KES ${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                
                const Divider(),
                
                // Payment Information
                const Text(
                  'Payment Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Total Amount', 'KES ${order.totalAmount.toStringAsFixed(2)}'),
                _buildInfoRow('Payment Status', order.mpesaStatus.toUpperCase()),
                if (order.mpesaReceiptNumber != null)
                  _buildInfoRow('M-Pesa Receipt', order.mpesaReceiptNumber!),
                if (order.customerPhone != null)
                  _buildInfoRow('Phone Number', order.customerPhone!),
                if (order.mpesaResponse != null)
                  _buildInfoRow('Response', order.mpesaResponse!),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                if (isPending)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to order status screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderStatusScreen(
                            orderId: order.orderId,
                            checkoutRequestId: order.checkoutRequestId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Check Payment Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                
                if (order.mpesaReceiptNumber != null)
                  const SizedBox(height: 8),
                  
                if (order.mpesaReceiptNumber != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      // Pass context to the share method
                      _shareReceipt(context, order);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Receipt'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareReceipt(BuildContext context, OrderModel order) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt: ${order.mpesaReceiptNumber}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}