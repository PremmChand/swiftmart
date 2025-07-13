import 'package:flutter/material.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Order/my_order_screen.dart';
import 'package:swiftmart/Views/Role_based_login/User/app_home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final double totalAmount;
  final String address;
  final String paymentMethod;

  const OrderSuccessScreen({
    super.key,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Confirmed"),
        centerTitle: true,
       elevation: 1,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
  onPressed: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AppHomeScreen()), // your actual home screen widget
      (Route<dynamic> route) => false, // remove all previous routes
    );
  },
),

      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Thank you for your purchase!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Your order has been placed successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Delivery Address"),
              subtitle: Text(address),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment Method"),
              subtitle: Text(paymentMethod),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Total Amount"),
              subtitle: Text("\$ ${totalAmount.toStringAsFixed(2)}"),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrderScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text("View My Orders"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
