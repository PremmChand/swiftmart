import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swiftmart/Common/Utils/cart_order_count.dart';
import 'package:swiftmart/Common/Utils/payment_method_list.dart';
import 'package:swiftmart/Model/model.dart';
import 'package:swiftmart/Provider/cart_provider.dart';
import 'package:swiftmart/Provider/favourite_provider.dart';
import 'package:swiftmart/Common/Utils/colors.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Activity/Controller/place_order_controller.dart';
import 'package:swiftmart/Views/Role_based_login/User/widgets/size_and_color.dart';
import 'package:swiftmart/Widgets/show_snackbar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final DocumentSnapshot<Object?> productitems;
  const ItemDetailScreen({super.key, required this.productitems});

  @override
  ConsumerState<ItemDetailScreen> createState() => ItemDetailScreenState();
}

class ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  int currentIndex = 0;
  int selectedColorIndex = 1;
  int selectedSizeIndex = 1;
  String? selectedPaymentMethodId;
  double? selectedPaymentBalance;
  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingOrderData;
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
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    showSnackbar(context, "Payment successful: ${response.paymentId}");
    // Trigger place order here
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showSnackbar(context, "Payment failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showSnackbar(context, "External Wallet: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double price =
        double.tryParse(widget.productitems['price'].toString()) ?? 0;
    final double discount =
        double.tryParse(
          widget.productitems['discountedPercentage'].toString(),
        ) ??
        0;
    final bool isDiscounted = widget.productitems['isDiscounted'] == true;

    // final finalPrice = num.parse(
    //   (widget.productitems['price'] *
    //           (1 - widget.productitems['discountedPercentage'] / 100))
    //       .toStringAsFixed(2),
    // );

    final double discountPercentage =
        double.tryParse(
          widget.productitems['discountedPercentage'].toString(),
        ) ??
        0;

    final double finalPrice = double.parse(
      (price * (1 - discountPercentage / 100)).toStringAsFixed(2),
    );

    final provider = ref.watch(favouriteProvider);

    CartProvider cp = ref.watch(cartService);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: fbackgroundColor2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Product Detail"),
        actions: const [
          CartOrderCount(),
          SizedBox(height: 20),

          // Stack(
          //   clipBehavior: Clip.none,
          //   children: [
          //     const Icon(Iconsax.shopping_bag, size: 28),
          //     Positioned(
          //       right: -3,
          //       top: -5,
          //       child: Container(
          //         padding: const EdgeInsets.all(4),
          //         decoration: const BoxDecoration(
          //           color: Colors.red,
          //           shape: BoxShape.circle,
          //         ),
          //         child: const Center(
          //           child: Text(
          //             "3",
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 20),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: fbackgroundColor2,
            height: size.height * 0.46,
            width: size.width,
            child: PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Hero(
                      tag: widget.productitems.id,
                      child: CachedNetworkImage(
                        imageUrl: widget.productitems['image'],
                        height: size.height * 0.4,
                        width: size.width * 0.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 4),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                index == currentIndex
                                    ? Colors.blue
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "H&M",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black26,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Icon(Icons.star, color: Colors.amber, size: 17),
                    Text(
                      "${Random().nextInt(2) + 3}.${Random().nextInt(5) + 4}",
                    ),
                    Text(" (${Random().nextInt(300) + 55})"),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        provider.toggleFavourite(widget.productitems);
                      },
                      child: Icon(
                        provider.isExist(widget.productitems)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            provider.isExist(widget.productitems)
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: size.width * 0.5,
                  child: Text(
                    widget.productitems['name'],
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "\$ $finalPrice",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.pink,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (isDiscounted)
                      Text(
                        "\$ ${widget.productitems['price']}.00",
                        style: const TextStyle(
                          color: Colors.black26,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  "$myDescription1 ${widget.productitems['name']} $myDescription2",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizeAndColor(
                  colors:
                      (widget.productitems.data()
                          as Map<String, dynamic>)['fcolor'] ??
                      [],
                  sizes:
                      (widget.productitems.data()
                          as Map<String, dynamic>)['size'] ??
                      [],
                  onColorSelected: (index) {
                    setState(() {
                      selectedColorIndex = index;
                    });
                  },
                  onSizeSelected: (index) {
                    setState(() {
                      selectedSizeIndex = index;
                    });
                  },
                  selectedColorIndex: selectedColorIndex,
                  selectedSizeIndex: selectedSizeIndex,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.white,
        elevation: 0,
        label: SizedBox(
          width: size.width * 0.9,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final productId = widget.productitems.id;
                      final productData =
                          widget.productitems.data() as Map<String, dynamic>;
                      // to get currently selected color and size
                      final selectedColor =
                          widget.productitems['fcolor'][selectedColorIndex];

                      final selectedSize =
                          widget.productitems['size'][selectedSizeIndex];
                      // call the service function
                      cp.addCart(
                        productId,
                        productData,
                        selectedColor,
                        selectedSize,
                      );
                      // nootify to user
                      showSnackbar(
                        context,
                        "${productData['name']} added to cart!",
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Iconsax.shopping_bag, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          "ADD TO CART",
                          style: TextStyle(
                            color: Colors.black,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Let's now work on buy button
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final productId =
                        widget.productitems.id; // to get document id
                    final productData =
                        widget.productitems.data() as Map<String, dynamic>;
                    final selectedColor =
                        widget.productitems['fcolor'][selectedColorIndex];
                    final selectedSize =
                        widget.productitems['size'][selectedSizeIndex];
                    _showOrderConfirmationDialog(
                      cp,
                      context,
                      productId,
                      productData,
                      selectedColor,
                      selectedSize,
                      finalPrice + 4.99,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        "BUY NOW",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderConfirmationDialog(
    CartProvider cp,
    BuildContext context,
    String productId,
    Map<String, dynamic> productData,
    String selectedColor,
    String selectedSize,
    double finalPrice,
  ) {
    String? addressError;
    final TextEditingController addressController = TextEditingController();

    // Local state for payment method inside dialog
    String? selectedPaymentMethodId;
    double? selectedPaymentBalance;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // FIX: Use SizedBox to constrain dialog content
            return AlertDialog(
              content: SizedBox(
                width: 320, // You can adjust width as needed
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Product Name: ${productData['name']}"),
                      Text("Quantity: 1"),
                      Text("Selected Color: $selectedColor"),
                      Text("Selected Size: $selectedSize"),
                      Text("Total Price: ₹ $finalPrice"),
                      const SizedBox(height: 10),

                      // Payment Method Selection
                      const Text(
                        "Select Payment Method",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Give PaymentMethodList a fixed height to avoid layout issues
                      SizedBox(
                        height: 180,
                        child: PaymentMethodList(
                          selectedPaymentMethodId: selectedPaymentMethodId,
                          selectedPaymentBalance: selectedPaymentBalance,
                          finalAmount: finalPrice,
                          onPaymentMethodSelected: (
                            String? methodId,
                            double? balance,
                          ) {
                            setDialogState(() {
                              selectedPaymentMethodId = methodId;
                              selectedPaymentBalance = balance;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Address Input
                      const Text(
                        "Add your delivery address",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: "Enter your address",
                          errorText: addressError,
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Confirm & Cancel Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () async {
                              // Payment method validation
                              if (selectedPaymentMethodId == null) {
                                showSnackbar(
                                  context,
                                  "Please select a payment method!",
                                );
                                return;
                              }

                              // Address validation
                              if (addressController.text.trim().length < 8) {
                                setDialogState(() {
                                  addressError =
                                      "Please enter a valid address (min 8 chars)";
                                });
                                return;
                              } else {
                                setDialogState(() {
                                  addressError = null;
                                });
                              }

                              // Razorpay online payment
                              if (selectedPaymentMethodId == "online") {
                                var options = {
                                  'key':
                                      'rzp_test_NFScMPmb7mMswP', // Replace with your key
                                  'amount': (finalPrice * 100).toInt(), // paise
                                  'name': 'SwiftMart',
                                  'description': 'Order Payment',
                                  'prefill': {
                                    'contact':
                                        '9999999999', // Replace with user contact
                                    'email':
                                        'test@example.com', // Replace with user email
                                  },
                                  'external': {
                                    'wallets': ['paytm'],
                                  },
                                };

                                try {
                                  _razorpay.open(options);
                                  // Store order data for success callback
                                  _pendingOrderData = {
                                    'productId': productId,
                                    'productData': productData,
                                    'selectedColor': selectedColor,
                                    'selectedSize': selectedSize,
                                    'finalPrice': finalPrice,
                                    'address': addressController.text,
                                  };
                                } catch (e) {
                                  debugPrint('Razorpay Error: $e');
                                }
                                return;
                              }

                              // Wallet/Other payment validation
                              if (selectedPaymentBalance == null ||
                                  selectedPaymentBalance! < finalPrice) {
                                showSnackbar(
                                  context,
                                  "Insufficient balance in selected payment method!",
                                );
                                return;
                              }

                              // Place order (for non-online payment)
                              placeOrder(
                                productId,
                                productData,
                                selectedColor,
                                selectedSize,
                                selectedPaymentMethodId!,
                                finalPrice,
                                addressController.text,
                                context,
                              );
                            },
                            child: const Text("Confirm"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
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

  // void _showOrderConfirmationDialog(
  //   CartProvider cp,
  //   BuildContext context,
  //   String productId,
  //   Map<String, dynamic> productData,
  //   String selectedColor,
  //   String selectedSize,
  //   double finalPrice,
  // ) {
  //   String? addressError;
  //   final TextEditingController addressController = TextEditingController();

  //   // Local state for payment method inside dialog
  //   String? selectedPaymentMethodId;
  //   double? selectedPaymentBalance;

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) {
  //           return AlertDialog(
  //             content: SizedBox(
  //               width: 300,
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text("Product Name: ${productData['name']}"),
  //                     Text("Quantity: 1"),
  //                     Text("Selected Color: $selectedColor"),
  //                     Text("Selected Size: $selectedSize"),
  //                     Text("Total Price: ₹ $finalPrice"),
  //                     const SizedBox(height: 10),

  //                     // Payment Method Selection
  //                     const Text(
  //                       "Select Payment Method",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 15,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Container(
  //                       height: 200,
  //                       child: PaymentMethodList(
  //                         selectedPaymentMethodId: selectedPaymentMethodId,
  //                         selectedPaymentBalance: selectedPaymentBalance,
  //                         finalAmount: finalPrice,
  //                         onPaymentMethodSelected: (
  //                           String? methodId,
  //                           double? balance,
  //                         ) {
  //                           setDialogState(() {
  //                             selectedPaymentMethodId = methodId;
  //                             selectedPaymentBalance = balance;
  //                           });
  //                         },
  //                       ),
  //                     ),

  //                     const SizedBox(height: 20),

  //                     // Address Input
  //                     const Text(
  //                       "Add your delivery address",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 15,
  //                       ),
  //                     ),
  //                     TextField(
  //                       controller: addressController,
  //                       decoration: InputDecoration(
  //                         hintText: "Enter your address",
  //                         errorText: addressError,
  //                         border: const OutlineInputBorder(),
  //                       ),
  //                     ),

  //                     const SizedBox(height: 20),

  //                     // Confirm & Cancel Buttons
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         TextButton(
  //                           onPressed: () async {
  //                             // Payment method validation
  //                             if (selectedPaymentMethodId == null) {
  //                               showSnackbar(
  //                                 context,
  //                                 "Please select a payment method!",
  //                               );
  //                               return;
  //                             }

  //                             // Address validation
  //                             if (addressController.text.trim().length < 8) {
  //                               setDialogState(() {
  //                                 addressError =
  //                                     "Please enter a valid address (min 8 chars)";
  //                               });
  //                               return;
  //                             } else {
  //                               setDialogState(() {
  //                                 addressError = null;
  //                               });
  //                             }

  //                             // Razorpay online payment
  //                             if (selectedPaymentMethodId == "online") {
  //                               var options = {
  //                                 'key':
  //                                     'rzp_test_NFScMPmb7mMswP', //'rzp_test_YourKeyHere', // Replace with your key
  //                                 'amount': (finalPrice * 100).toInt(), // paise
  //                                 'name': 'SwiftMart',
  //                                 'description': 'Order Payment',
  //                                 'prefill': {
  //                                   'contact':
  //                                       '9999999999', // Replace with user contact
  //                                   'email':
  //                                       'test@example.com', // Replace with user email
  //                                 },
  //                                 'external': {
  //                                   'wallets': ['paytm'],
  //                                 },
  //                               };

  //                               try {
  //                                 _razorpay.open(options);
  //                                 // Store order data for success callback
  //                                 _pendingOrderData = {
  //                                   'productId': productId,
  //                                   'productData': productData,
  //                                   'selectedColor': selectedColor,
  //                                   'selectedSize': selectedSize,
  //                                   'finalPrice': finalPrice,
  //                                   'address': addressController.text,
  //                                 };
  //                               } catch (e) {
  //                                 debugPrint('Razorpay Error: $e');
  //                               }
  //                               return;
  //                             }

  //                             // Wallet/Other payment validation
  //                             if (selectedPaymentBalance == null ||
  //                                 selectedPaymentBalance! < finalPrice) {
  //                               showSnackbar(
  //                                 context,
  //                                 "Insufficient balance in selected payment method!",
  //                               );
  //                               return;
  //                             }

  //                             // Place order (for non-online payment)
  //                             placeOrder(
  //                               productId,
  //                               productData,
  //                               selectedColor,
  //                               selectedSize,
  //                               selectedPaymentMethodId!,
  //                               finalPrice,
  //                               addressController.text,
  //                               context,
  //                             );
  //                           },
  //                           child: const Text("Confirm"),
  //                         ),
  //                         TextButton(
  //                           onPressed: () {
  //                             Navigator.of(context).pop();
  //                           },
  //                           child: const Text("Cancel"),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // void _showOrderConfirmationDialog(
  //   CartProvider cp,
  //   BuildContext context,
  //   String productId,
  //   Map<String, dynamic> productData,
  //   String selectedColor,
  //   String selectedSize,
  //   finalPrice,
  // ) {
  //   String? AddressError;
  //   TextEditingController addressController = TextEditingController();
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
  //                   Text("Product Name: ${productData['name']}"),
  //                   Text("Quantity: 1"),
  //                   Text("Selected Color: $selectedColor"),
  //                   Text("Selected Size: $selectedSize"),
  //                   Text("Total Price: \$ $finalPrice"),
  //                   SizedBox(height: 10),
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
  //                   PaymentMethodList(
  //                     selectedPaymentMethodId: selectedPaymentMethodId,
  //                     selectedPaymentBalance: selectedPaymentBalance,
  //                     finalAmount: finalPrice,
  //                     onPaymentMethodSelected: (p0, p1) {
  //                       setDialogState(() {
  //                         selectedPaymentMethodId = p0;
  //                         selectedPaymentBalance = p1;
  //                       });
  //                     },
  //                   ),

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
  //                       errorText: AddressError,
  //                       border: const OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   //confirm and  cancel button
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       TextButton(
  //                         onPressed: () {
  //                           // lets vaidate the cofirm button
  //                           //   if (selectedPaymentMethodId == null) {
  //                           //     showSnackbar(
  //                           //       context,
  //                           //       "Please select a payment method!",
  //                           //     );
  //                           //   } else if (selectedPaymentBalance == null ||
  //                           //       selectedPaymentBalance! < finalPrice) {
  //                           //     showSnackbar(
  //                           //       context,
  //                           //       "Insufficient balance in selected payment method!",
  //                           //     );
  //                           //   } else if (addressController.text.length < 8) {
  //                           //     setDialogState(() {
  //                           //       AddressError =
  //                           //           "Your address must be reflect your address identity";
  //                           //     });
  //                           //   } else {
  //                           //     //for single items order place
  //                           //     placeOrder(
  //                           //       productId,
  //                           //       productData,
  //                           //       selectedColor,
  //                           //       selectedSize,
  //                           //       selectedPaymentMethodId!,
  //                           //       finalPrice,
  //                           //       addressController.text,
  //                           //       context,
  //                           //     );
  //                           //   }

  //                           // New added code for razorpay integratopm

  //                           if (selectedPaymentMethodId == null) {
  //                             showSnackbar(
  //                               context,
  //                               "Please select a payment method!",
  //                             );
  //                           } else if (selectedPaymentMethodId == "online") {
  //                             if (addressController.text.length < 8) {
  //                               setDialogState(() {
  //                                 AddressError =
  //                                     "Your address must reflect your address identity";
  //                               });
  //                               return;
  //                             }

  //                             // Trigger Razorpay for online payment
  //                             var options = {
  //                               'key':
  //                                   'rzp_test_YourKeyHere', // TODO: Replace with your Razorpay key
  //                               'amount':
  //                                   (finalPrice * 100).toInt(), // In paise
  //                               'name': 'SwiftMart',
  //                               'description': 'Order Payment',
  //                               'prefill': {
  //                                 'contact':
  //                                     '9999999999', // You can fetch user data if available
  //                                 'email': 'test@example.com',
  //                               },
  //                               'external': {
  //                                 'wallets': ['paytm'],
  //                               },
  //                             };

  //                             try {
  //                               _razorpay.open(options);
  //                               // Store required order details temporarily for success callback
  //                               _pendingOrderData = {
  //                                 'productId': productId,
  //                                 'productData': productData,
  //                                 'selectedColor': selectedColor,
  //                                 'selectedSize': selectedSize,
  //                                 'finalPrice': finalPrice,
  //                                 'address': addressController.text,
  //                               };
  //                             } catch (e) {
  //                               debugPrint('Razorpay Error: $e');
  //                             }
  //                           } else if (selectedPaymentBalance == null ||
  //                               selectedPaymentBalance! < finalPrice) {
  //                             showSnackbar(
  //                               context,
  //                               "Insufficient balance in selected payment method!",
  //                             );
  //                           } else if (addressController.text.length < 8) {
  //                             setDialogState(() {
  //                               AddressError =
  //                                   "Your address must reflect your address identity";
  //                             });
  //                           } else {
  //                             //for single items order place
  //                             placeOrder(
  //                               productId,
  //                               productData,
  //                               selectedColor,
  //                               selectedSize,
  //                               selectedPaymentMethodId!,
  //                               finalPrice,
  //                               addressController.text,
  //                               context,
  //                             );
  //                           }
  //                         },

  //                         child: const Text("Confirm"),
  //                       ),
  //                       TextButton(
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                         },
  //                         child: const Text("Cancel"),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
