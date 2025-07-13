import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Common/Utils/payment_method_list.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Activity/Model/cart_model.dart';

final cartService = ChangeNotifierProvider<CartProvider>(
  (ref) => CartProvider(),
);

class CartProvider with ChangeNotifier {
  List<CartModel> _carts = [];
  List<CartModel> get carts => _carts;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CartProvider() {
    loadCartItems(); // load cart items on initialization
  }
  void reset() {
    _carts = [];
    notifyListeners();
  }

  final userId = FirebaseAuth.instance.currentUser?.uid;
  set carts(List<CartModel> carts) {
    _carts = carts;
    notifyListeners();
  }

  Future<void> addCart(
    String productId,
    Map<String, dynamic> productData,
    String selectedColor,
    String selectedSize,
  ) async {
    int index = _carts.indexWhere(
      (elements) => elements.productId == productId,
    );
    if (index != -1) {
      var existingItem = _carts[index];
      _carts[index] = CartModel(
        productId: productId,
        productData: productData,
        quantity: existingItem.quantity + 1, // increase quantity
        selectedColor: selectedColor, // Updated selected color
        selectedSize: selectedSize, // Update  selected size
      );
      await _updateCartInFirebase(productId, _carts[index].quantity);
    } else {
      // items does not exist, and new entry
      _carts.add(
        CartModel(
          productId: productId,
          productData: productData,
          quantity: 1, //initially one items must be required
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
      await _firestore.collection("userCart").doc(productId).set({
        'productData': productData,
        "quantity": 1,
        "selectedColor": selectedColor,
        "selectedSize": selectedSize,
        "userId": userId,
      });
    }
    notifyListeners();
  }

  // increa quantity

  Future<void> addQuantity(String productId) async {
    int index = _carts.indexWhere((element) => element.productId == productId);
    _carts[index].quantity += 1;
    await _updateCartInFirebase(productId, _carts[index].quantity);
    notifyListeners();
  }

  // Decrease quantity or remove items
  Future<void> decreaseQuantity(String productId) async {
    int index = _carts.indexWhere((element) => element.productId == productId);
    _carts[index].quantity -= 1;
    if (_carts[index].quantity <= 0) {
      _carts.removeAt(index);
      await _firestore.collection("userCart").doc(productId).delete();
    } else {
      await _updateCartInFirebase(productId, _carts[index].quantity);
    }
    notifyListeners();
  }

  //Check if the product exist in the cart
  bool productExist(String productId) {
    return _carts.any((element) => element.productId == productId);
  }

  //calculate total cart values
  // double totalCart() {
  //   double total = 0;
  //   for (var i = 0; i < _carts.length; i++) {
  //     final finalPrice = num.parse(
  //       (_carts[i].productData['price'] *
  //               (1 - _carts[i].productData['discountedPercentage'] / 100))
  //           .toStringAsFixed(2),
  //     );

  //     total += _carts[i].quantity * (finalPrice);
  //   }
  //   return total;
  // }

  double totalCart() {
    double total = 0;
    for (var i = 0; i < _carts.length; i++) {
      final product = _carts[i].productData;

      // Convert price and discount safely
      final price = num.tryParse(product['price'].toString()) ?? 0;
      final discount =
          num.tryParse(product['discountedPercentage'].toString()) ?? 0;

      final finalPrice = price * (1 - discount / 100);

      total += _carts[i].quantity * finalPrice;
    }
    return total;
  }

  //Load cart items from the firebase
  Future<void> loadCartItems() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection("userCart")
              .where("uid", isEqualTo: userId)
              .get();
      _carts =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CartModel(
              productId: doc.id,
              productData: data['productData'],
              quantity: data['quantity'],
              selectedColor: data['selectedColor'],
              selectedSize: data['selectedSize'],
            );
          }).toList();
    } catch (e) {
      throw e.toString();
    }
    notifyListeners();
  }

  // save orderList in firebase

  Future<void> saveOrder(
    String userId,
    BuildContext context,
    paymentMethodId,
    finalPrice,
    address,
  ) async {
    if (_carts.isEmpty) return; // no items to save
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
        transaction.update(paymentRef, {
          'balancce': currentBalance - finalPrice,
        });
        //create order data
        final orderData = {
          'userId': userId,
          'items':
              _carts.map((cartItems) {
                return {
                  'productId': cartItems.productId,
                  'name': cartItems.productData['name'],
                  'quantity': cartItems.quantity,
                  'selectedColor': cartItems.selectedColor,
                  'selectedSize': cartItems.selectedSize,
                  'price': cartItems.productData['price'],
                };
              }).toList(),
          'totalPrice': finalPrice,
          'status': 'pending', //initial status pending
          'createdAt': FieldValue.serverTimestamp(),
          'address': address,
        };
        // create new order
        final orderRef = FirebaseFirestore.instance.collection("Orders").doc();
        transaction.set(orderRef, orderData);
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //Remove cartItems from firebase
  Future<void> deleteCartItems(String productId) async {
    int index = _carts.indexWhere((element) => element.productId == productId);
    if (index != -1) {
      _carts.removeAt(index); // remove item from local cart
      await _firestore
          .collection("userCart")
          .doc(productId)
          .delete(); // Remove item from firebase
      notifyListeners(); //notiflistener to update the ui
    }
  }

  //Update cart items in firebase
  Future<void> _updateCartInFirebase(String productId, int quantity) async {
    try {
      await _firestore.collection("userCart").doc(productId).update({
        "quantity": quantity,
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
