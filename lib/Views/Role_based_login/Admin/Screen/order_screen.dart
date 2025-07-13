// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Order/order_detail.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Order"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Orders").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              var order = orders[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_long,
                              size: 20,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Order ID: ${order.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Total: \$${order['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepOrange,
                          ),
                        ),
                        Text(
                          "Delivery location : ${order['address']}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        //  Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       vertical: 4,
                        //       horizontal: 10,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.green.shade100,
                        //       borderRadius: BorderRadius.circular(20),
                        //     ),
                        //     child: const Text(
                        //       "Status: Pending",
                        //       style: TextStyle(
                        //         color: Colors.green,
                        //         fontSize: 13,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Order Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection("Orders").doc(orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found."));
          }

          final orderData = snapshot.data!;
          final items = orderData['items'] as List<dynamic>;

          final data = orderData.data() as Map<String, dynamic>?;

          String formattedDate = "Unknown date";

          if (data != null && data['createdAt'] != null) {
            final Timestamp createdAtTimestamp = data['createdAt'] as Timestamp;
            final DateTime createdAtDateTime = createdAtTimestamp.toDate();
            formattedDate = DateFormat(
              'dd MMM yyyy • hh:mm a',
            ).format(createdAtDateTime);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Ordered On: $formattedDate",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildChip("Qty: ${item['quantity']}"),
                          const SizedBox(width: 10),
                          _buildChip("Color: ${item['selectedColor']}"),
                          const SizedBox(width: 10),
                          _buildChip("Size: ${item['selectedSize']}"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${item['price'].toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Pending",
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
