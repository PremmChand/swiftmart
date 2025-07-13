// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:swiftmart/Widgets/my__button.dart';
import 'package:swiftmart/Widgets/show_snackbar.dart';

class AddPaymentMethod extends StatefulWidget {
  const AddPaymentMethod({super.key});

  @override
  State<AddPaymentMethod> createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final maskFormatter = MaskTextInputFormatter(
    mask: "**** **** **** ****", // defining the pattern
    filter: {"*": RegExp(r'[0-9]')}, // allows only digits
  );
  double balance = 0.0;
  late Future<List<Map<String, dynamic>>> paymentSystemsFuture;
  String? selectedPaymentSystem;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? selectedPaymentSystemData;

  @override
  void initState() {
    super.initState();
    paymentSystemsFuture = fetchPaymentSystems();
  }

  // ✅ Correct Firestore collection name: payment_methods
  Future<List<Map<String, dynamic>>> fetchPaymentSystems() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("payment_methods").get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Unnamed',
          'image': data['image'] ?? '',
        };
      }).toList();
    } catch (e) {
      print(" Error fetching payment systems: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payment Method"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: paymentSystemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No payment systems available");
                    }

                    return SizedBox(
                      height: 40,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        elevation: 2,
                        value: selectedPaymentSystem,
                        hint: const Text("Select Payment System"),
                        items:
                            snapshot.data!.map((system) {
                              return DropdownMenuItem<String>(
                                value: system['name'],
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: system['image'],
                                      width: 30,
                                      height: 30,
                                      placeholder:
                                          (_, __) => const SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      errorWidget:
                                          (_, __, ___) =>
                                              const Icon(Icons.error, size: 30),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(system['name']),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentSystem = value;
                            selectedPaymentSystemData = snapshot.data!
                                .firstWhere(
                                  (system) => system['name'] == value,
                                );
                          });
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _userNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "CARD Holder Name",
                    hintText: "eg.John Doe",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 6) {
                      return "Provide your full name";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    hintText: "eg.1232 4564 3454 8675",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [maskFormatter],
                  validator: (value) {
                    if (value == null ||
                        value.replaceAll(' ', '').length != 16) {
                      return "Card number must be exactly 16 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _balanceController,
                  decoration: InputDecoration(
                    labelText: "Balance",
                    prefixText: "\$",
                    hintText: "40",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => balance = double.tryParse(value) ?? 0.0,
                ),
                const SizedBox(height: 10),

                MyButton(
                  onTab: () => addPaymentMethod(),
                  buttonText: "Add Payment Method",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) {
      return; // dont proceed if the form is invalid
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && selectedPaymentSystem != null) {
      final paymentCollection = FirebaseFirestore.instance.collection(
        "User Payment Method",
      );
      //check if the payment method already exists for this user
      final existingMethods =
          await paymentCollection
              .where('userId', isEqualTo: userId)
              .where(
                "paymentSystem",
                isEqualTo: selectedPaymentSystemData!['name'],
              )
              .get();

      if (existingMethods.docs.isNotEmpty) {
        showSnackbar(context, "You have already added this payment method!");
        return;
      }
      await paymentCollection.add({
        'userName': _userNameController.text.trim(),
        'cardNumber': _cardNumberController.text.trim(),
        'balance': balance,
        'userId': userId,
        'paymentSystem': selectedPaymentSystemData!['name'],
        'image': selectedPaymentSystemData!['image'],
      });
      showSnackbar(context, "Payment method successfully added!");
      Navigator.pop(context);
    } else {
      showSnackbar(context, "Failed to add payment method.Please try again.");
    }
  }

  
}
