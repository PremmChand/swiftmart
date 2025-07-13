// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Payment/add_payment.dart';
import 'package:swiftmart/Widgets/show_snackbar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? userId;
  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser?.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Methods"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // now lets displlay added payment methods
      body:
          userId == null
              ? Center(child: Text("Please login to view payment methods."))
              : SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child: StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection("User Payment Method")
                          .where("userId", isEqualTo: userId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final methods = snapshot.data!.docs;
                    if (methods.isEmpty) {
                      return const Center(
                        child: Text(
                          "No payment methods found. Please add a payment methods",
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: methods.length,
                      itemBuilder: (context, index) {
                        final method = methods[index];
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: method['image'],
                            height: 50,
                            width: 50,
                          ),
                          title: Text(method['paymentSystem']),
                          subtitle: const Text(
                            "Activate",
                            style: TextStyle(color: Colors.green),
                          ),
                          trailing: MaterialButton(
                            onPressed:
                                () => _showAddFundDialog(context, method),
                            child: const Text("Add Fund"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,

        onPressed: () {
          //Navigation
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPaymentMethod()),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  void _showAddFundDialog(BuildContext context, DocumentSnapshot method) {
    TextEditingController amountConteroller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Add Funds"),
            content: TextField(
              controller: amountConteroller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                labelText: "Amount",
                prefixText: "\$",
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final amount = double.tryParse(amountConteroller.text);
                  if (amount == null || amount <= 0) {
                    showSnackbar(
                      context,
                      "Please enter a valid postive amount",
                    );
                    return;
                  }
                  try {
                    await method.reference.update({
                      'balance': FieldValue.increment(amount),
                    });
                    Navigator.pop(context);
                    showSnackbar(context, "Funds Added Successfully!");
                  } catch (e) {
                    showSnackbar(context, "Error adding funds: $e");
                  }
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }
}
