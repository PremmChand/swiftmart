import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Common/Utils/payment_method_list.dart';
import 'package:swiftmart/Provider/cart_provider.dart';
import 'package:swiftmart/Common/Utils/colors.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Activity/Add%20To%20Cart/Widgets/cart_items.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Order/order_success_screen.dart';
import 'package:swiftmart/Widgets/show_snackbar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  String? selectedPaymentMethodId;
  double? selectedPaymentBalance;
  
  TextEditingController addressController = TextEditingController();
  late Razorpay _razorpay;
  final razorpayKey = dotenv.env['RAZORPAY_KEY_ID'];
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    addressController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final cp = ref.read(cartService);
    await _saveOrder(cp, context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showSnackbar(context, "Payment failed. Please try again.");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showSnackbar(context, "External wallet selected.");
  }

  void _startRazorpayPayment(double amount) {
    var options = {
      'key':razorpayKey,
      'amount': (amount * 100).toInt(),
      'name': 'SwiftMart',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@razorpay.com'
      },
    };
    _razorpay.open(options);
  }

  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(cartService);
    final carts = cp.carts.reversed.toList();
    return Scaffold(
      backgroundColor: fbackgroundColor1,
      appBar: AppBar(
        backgroundColor: fbackgroundColor1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        title: const Text(
          "My Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: carts.isNotEmpty
                ? ListView.builder(
                    itemCount: carts.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GestureDetector(
                          onTap: () {},
                          onLongPress: () {
                            cp.deleteCartItems(carts[index].productId);
                          },
                          child: CartItems(cart: carts[index]),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Your cart is empty!",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          if (carts.isNotEmpty) _buildSummarySecton(context, cp),
        ],
      ),
    );
  }

  Widget _buildSummarySecton(BuildContext context, CartProvider cp) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Delivery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              const Expanded(child: DottedLine()),
              const SizedBox(width: 10),
              const Text("\$4.99", style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text("Total Order", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              const Expanded(child: DottedLine()),
              const SizedBox(width: 10),
              Text("\$ ${(cp.totalCart()).toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 40),
          MaterialButton(
            color: Colors.black,
            height: 70,
            minWidth: MediaQuery.of(context).size.width - 50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () {
              _showOrderConfirmationDialog(context, cp);
            },
            child: Text(
              "Pay \$ ${((cp.totalCart() + 4.99).toStringAsFixed(2))}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, CartProvider cp) {
    String? addressError;
    double finalAmount = cp.totalCart() + 4.99;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text("Confirm Your Order", style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: cp.carts.map((CartItem) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text("${CartItem.productData['name']} x ${CartItem.quantity}"),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 10),
                              Text("Total Payable Price: \$ ${finalAmount.toStringAsFixed(2)}"),
                              const SizedBox(height: 20),
                              const Text("Select Payment Method", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 200,
                                child: PaymentMethodList(
                                  selectedPaymentMethodId: selectedPaymentMethodId,
                                  selectedPaymentBalance: selectedPaymentBalance,
                                  finalAmount: finalAmount,
                                  onPaymentMethodSelected: (p0, p1) {
                                    setDialogState(() {
                                      selectedPaymentMethodId = p0;
                                      selectedPaymentBalance = p1;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text("Add your delivery address", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              TextField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  hintText: "Enter your address",
                                  errorText: addressError,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedPaymentMethodId == null) {
                                  showSnackbar(context, "Please select a payment method!");
                                } else if (selectedPaymentMethodId == 'online') {
                                  if (addressController.text.length < 8) {
                                    setDialogState(() {
                                      addressError = "Your address must reflect your identity";
                                    });
                                  } else {
                                    _startRazorpayPayment(finalAmount);
                                  }
                                } else if (selectedPaymentBalance == null || selectedPaymentBalance! < finalAmount) {
                                  showSnackbar(context, "Insufficient balance in selected payment method!");
                                } else if (addressController.text.length < 8) {
                                  setDialogState(() {
                                    addressError = "Your address must reflect your identity";
                                  });
                                } else {
                                  _saveOrder(cp, context);
                                }
                              },
                              child: const Text("Confirm"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveOrder(CartProvider cp, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showSnackbar(context, "You need to be logged in to place an order!");
      return;
    }
    await cp.saveOrder(userId, context, selectedPaymentMethodId, cp.totalCart() + 4.99, addressController.text);
    showSnackbar(context, "Order placed successfully");
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyOrderScreen()));
    Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => OrderSuccessScreen(
      totalAmount: cp.totalCart() + 4.99,
      address: addressController.text,
      paymentMethod: selectedPaymentMethodId ?? 'Unknown',
    ),
  ),
  (route) => false,
);

 
  }

}

  // void _showOrderConfirmationDialog1(BuildContext context, CartProvider cp) {
  //   String? addressError;
  //   double finalAmount = cp.totalCart() + 4.99;

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) {
  //           return AlertDialog(
  //             title: Text("Confirm Your Order"),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children:
  //                         cp.carts.map((CartItem) {
  //                           return Padding(
  //                             padding: const EdgeInsets.only(bottom: 4.0),
  //                             child: Text(
  //                               "${CartItem.productData['name']} x ${CartItem.quantity}",
  //                             ),
  //                           );
  //                         }).toList(),
  //                   ),
  //                   Text(
  //                     "Total Payable Price: \$ ${(cp.totalCart() + 4.99).toStringAsFixed(2)}",
  //                   ),
  //                   // to display the list of availbale payment menthod
  //                   const SizedBox(height: 10),
  //                   const Text(
  //                     "Select Payment Method",
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 15,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),

  //                   //now add payment method
  //                   SizedBox(
  //                     height: 150, // Adjust this height as needed
  //                     child: PaymentMethodList(
  //                       selectedPaymentMethodId: selectedPaymentMethodId,
  //                       selectedPaymentBalance: selectedPaymentBalance,
  //                       finalAmount: finalAmount,
  //                       onPaymentMethodSelected: (p0, p1) {
  //                         setDialogState(() {
  //                           selectedPaymentMethodId = p0;
  //                           selectedPaymentBalance = p1;
  //                         });
  //                       },
  //                     ),
  //                   ),

  //                   // PaymentMethodList(
  //                   //   selectedPaymentMethodId: selectedPaymentMethodId,
  //                   //   selectedPaymentBalance: selectedPaymentBalance,
  //                   //   finalAmount: cp.totalCart() + 4.99,
  //                   //   onPaymentMethodSelected: (p0, p1) {
  //                   //     setDialogState(() {
  //                   //       selectedPaymentMethodId = p0;
  //                   //       selectedPaymentBalance = p1;
  //                   //     });
  //                   //   },
  //                   // ),

  //                   // to add delivery address
  //                   const Text(
  //                     "Add your delivery address",
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 15,
  //                     ),
  //                   ),
  //                   TextField(
  //                     controller: addressController,
  //                     decoration: InputDecoration(
  //                       hintText: "Enter your address",
  //                       errorText: addressError,
  //                       border: const OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   // lets vaidate the cofirm button
  //                   if (selectedPaymentMethodId == null) {
  //                     showSnackbar(context, "Please select a payment method!");
  //                   } else if (selectedPaymentBalance == null ||
  //                       selectedPaymentBalance! < finalAmount) {
  //                     //cp.totalCart() + 4.99 replaced by finalAmount
  //                     showSnackbar(
  //                       context,
  //                       "Insufficient balance in selected payment method!",
  //                     );
  //                   } else if (addressController.text.length < 8) {
  //                     setDialogState(() {
  //                       addressError =
  //                           "Your address must be reflect your address identity";
  //                     });
  //                   } else {
  //                     _saveOrder(cp, context);
  //                   }
  //                 },
  //                 child: const Text("Confirm"),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text("Cancel"),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<void> _saveOrder(CartProvider cp, context) async {
  //   final userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) {
  //     showSnackbar(context, "You need to be logged in to place an order!");
  //     return;
  //   }
  //   // save the order to the firebase
  //   await cp.saveOrder(
  //     userId,
  //     context,
  //     selectedPaymentMethodId,
  //     cp.totalCart() + 4.99,
  //     addressController.text,
  //   );
  //   showSnackbar(context, "Order placed successfully");
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const MyOrderScreen()),
  //   );
  // }

