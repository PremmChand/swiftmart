import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentMethodList extends StatefulWidget {
  final String? selectedPaymentMethodId;
  final double? selectedPaymentBalance;
  final double? finalAmount;
  final Function(String?, double?) onPaymentMethodSelected;

  const PaymentMethodList({
    super.key,
    required this.selectedPaymentMethodId,
    required this.selectedPaymentBalance,
    required this.finalAmount,
    required this.onPaymentMethodSelected,
  });

  @override
  State<PaymentMethodList> createState() => _PaymentMethodListState();
}

class _PaymentMethodListState extends State<PaymentMethodList> {
  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return SizedBox(
      // Remove fixed height for better flexibility
      width: double.infinity,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("User Payment Method")
                .where("userId", isEqualTo: uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No payment methods found"));
          }

          List<Map<String, dynamic>> paymentDocs =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'paymentSystem': data['paymentSystem'] ?? 'Unknown',
                  'image': data['image'] ?? 'https://via.placeholder.com/50',
                  'balance':
                      (data['balance'] is num)
                          ? data['balance']
                          : double.tryParse(data['balance'].toString()) ?? 0.0,
                };
              }).toList();

          // Add dummy Razorpay option
          final razorpayDummy = {
            'id': 'online',
            'paymentSystem': 'Razorpay (Online)',
            'image':'https://upload.wikimedia.org/wikipedia/commons/6/6a/Razorpay_logo.svg',
            'balance': double.infinity,
          };

          final paymentMethod = [...paymentDocs, razorpayDummy];

          if (paymentMethod.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No Payment Method Available"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to add payment method screen
                    },
                    child: const Text(
                      "Click Here to Add",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SizedBox(
            height: 150, // or any appropriate height for your dialog
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: paymentMethod.length,
              itemBuilder: (context, index) {
                final payment = paymentMethod[index];
                final isRazorpay = payment['id'] == 'online';

                return Material(
                  color:
                      widget.selectedPaymentMethodId == payment['id']
                          ? Colors.blue[50]
                          : Colors.transparent,
                  child: ListTile(
                    trailing: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(payment['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(payment['paymentSystem']),
                    subtitle:
                        isRazorpay
                            ? const Text("Online UPI/Card Payment")
                            : availableBalance(
                              payment['balance'],
                              widget.finalAmount,
                            ),
                    selected: widget.selectedPaymentMethodId == payment['id'],
                    onTap: () {
                      widget.onPaymentMethodSelected(
                        payment['id'],
                        isRazorpay
                            ? double.infinity
                            : (payment['balance'] is num
                                ? (payment['balance'] as num).toDouble()
                                : double.tryParse(
                                      payment['balance'].toString(),
                                    ) ??
                                    0.0),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget availableBalance(dynamic balance, double? finalAmount) {
    if (balance == null || finalAmount == null) return const SizedBox();

    if (balance is! num) {
      balance = double.tryParse(balance.toString()) ?? 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (balance >= finalAmount)
          const Text("Active", style: TextStyle(color: Colors.green)),
        if (balance < finalAmount)
          const Text(
            "Insufficient Balance",
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}

//The  below old code that has paypal and mastercard implementation

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class PaymentMethodList extends StatefulWidget {
//   final String? selectedPaymentMethodId;
//   final double? selectedPaymentBalance;
//   final double? finalAmount;
//   final Function(String?, double?) onPaymentMethodSelected;
//   const PaymentMethodList({
//     super.key,
//     required this.selectedPaymentMethodId,
//     required this.selectedPaymentBalance,
//     required this.finalAmount,
//     required this.onPaymentMethodSelected,
//   });

//   @override
//   State<PaymentMethodList> createState() => _PaymentMethodListState();
// }

// class _PaymentMethodListState extends State<PaymentMethodList> {
//   @override
//   Widget build(BuildContext context) {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     return SizedBox(
//       height: 150,
//       width: double.maxFinite,
//       child: StreamBuilder(
//         stream:
//             FirebaseFirestore.instance
//                 .collection("User Payment Method")
//                 .where("userId", isEqualTo: uid)
//                 .snapshots(),
//         builder: (context, snapshot) {
//           //Testing code
//           print("Current UID: ${FirebaseAuth.instance.currentUser!.uid}");
//           print("C onnection state: ${snapshot.connectionState}");
//           print("Has data: ${snapshot.hasData}");
//           print("Docs length: ${snapshot.data?.docs.length}");
//           print("Error: ${snapshot.error}");

//           if (snapshot.hasData) {
//             for (var doc in snapshot.data!.docs) {
//               print("Payment Method: ${doc.data()}");
//             }
//           }

//           //

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("No Payment Method Available"),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to add payment method screen
//                     },
//                     child: const Text(
//                       "Click Here to Add",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//           final paymentMethod = snapshot.data!.docs;
//           // (!snapshot.hasData){
//           //   return Center(
//           //     child: CircularProgressIndicator(),
//           //   );
//           // };
//           // final paymentMethod = snapshot.data!.docs;
//           // if(paymentMethod.isEmpty){
//           //   return Center(
//           //   child: Column(
//           //     children: [
//           //       Text("No Payment Method Available"),
//           //       GestureDetector(
//           //         onTap: (){},
//           //         child: const Text(
//           //           "Click Here to Add",
//           //           style: TextStyle(
//           //             fontWeight: FontWeight.bold,
//           //             color: Colors.blue,
//           //             decoration: TextDecoration.underline,
//           //             decorationColor: Colors.blue,
//           //           ),
//           //         ),
//           //       )
//           //     ],
//           //   ),
//           //   );
//           // }
//           return ListView.builder(
//             itemCount: paymentMethod.length,
//             itemBuilder: (context, index) {
//               var payment = paymentMethod[index];
//               return Material(
//                 color:
//                     widget.selectedPaymentMethodId == payment.id
//                         ? Colors.blue[50]
//                         : Colors.transparent,
//                 child: ListTile(
//                   trailing: Container(
//                     height: 50,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: CachedNetworkImageProvider(payment['image']),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   title: Text(payment['paymentSystem']),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       availableBalance(payment["balance"], widget.finalAmount),
//                     ],
//                   ),
//                   // selected: widget.onPaymentMethodSelected(
//                   //   payment.id,
//                   //   (payment['balance'] as num).toDouble(),
//                   // ),//commented by me
//                   selected: widget.selectedPaymentMethodId == payment.id,
//                   onTap: () {
//                     widget.onPaymentMethodSelected(
//                       payment.id,
//                       (payment['balance'] as num).toDouble(),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   availableBalance(balance, finalAmount) {
//     if (balance == null || finalAmount == null) return const SizedBox();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (balance > finalAmount)
//           const Text("Active", style: TextStyle(color: Colors.green)),
//         if (balance < finalAmount)
//           const Text(
//             "Insufficient Balance",
//             style: TextStyle(color: Colors.red),
//           ),
//       ],
//     );
//   }
// }
