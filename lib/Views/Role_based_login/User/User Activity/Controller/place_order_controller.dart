

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Order/my_order_screen.dart';
import 'package:swiftmart/Widgets/show_snackbar.dart';

Future<void> placeOrder(
  String productId,
  Map<String, dynamic> productData,
  String selectedColor,
  String selectedSize,
  String paymentMethodId,
  num finalPrice,
  String address,
  BuildContext context,
) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    showSnackbar(context, "User not logged in. Please login to place order.");
    return;
  }

  final paymentRef = FirebaseFirestore.instance
      .collection("User Payment Method")
      .doc(paymentMethodId);
  try {
    //user transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // get current payment  method data
      final snapshot = await transaction.get(paymentRef);
      if (!snapshot.exists) {
        throw Exception("Payment method not found");
      }
      final currentBalance = snapshot['balance'] as num;
      if (currentBalance < finalPrice) {
        throw Exception("Innsufficient funds");
      }
      transaction.update(paymentRef, {'balancce': currentBalance - finalPrice,
      });
      //create order data
      final orderData = {
        'userId': userId,
        'items': [
          {
            'productId': productId,
            'name': productData['name'],
            'quantity': 1,
            'selectedColor': selectedColor,
            'selectedSize': selectedSize,
            'price': productData['price'],
          },
        ],

        'totalPrice': finalPrice,
        'status': 'pending', //initial status pending
        'createdAt': FieldValue.serverTimestamp(),
        'address': address,
      };
      // create new order
      final orderRef = FirebaseFirestore.instance.collection("Orders").doc();
      transaction.set(orderRef, orderData);
    });
    showSnackbar(context, "Order Placed Successfully!");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyOrderScreen()),
    );
  } on  FirebaseException catch (e) {
    showSnackbar(context, "Firebase Error: ${e.toString()}");
  } on Exception catch(e){
      showSnackbar(context, "Error: ${e.toString()}");
  }
}
