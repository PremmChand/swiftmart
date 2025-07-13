import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favouriteProvider = ChangeNotifierProvider<FavouriteProvider>(
  (ref) => FavouriteProvider(),
);

class FavouriteProvider extends ChangeNotifier {
  List<String> favouriteIds = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> get favourites => favouriteIds;

  void reset() {
    favouriteIds = [];
    notifyListeners();
  }

  // check if  product is favouriite
  bool isExist(DocumentSnapshot product) {
    return favouriteIds.contains(product.id);
  }

  final userId = FirebaseAuth.instance.currentUser?.uid;
  FavouriteProvider() {
    loadFavourites();
  }
  //toggle favourite states
  void toggleFavourite(DocumentSnapshot product) async {
    String productId = product.id;
    if (favouriteIds.contains(productId)) {
      favouriteIds.remove(productId);
      await removeFavourite(productId);
    } else {
      favouriteIds.add(productId);
      await addFavourite(productId); // add item to favourite collection
    }
    notifyListeners();
  }

  // add favourite to firestore
  Future<void> addFavourite(String productId) async {
    try {
      await firestore.collection("userFavourite").doc(productId).set({
        "isFavourite": true,
        "userId": userId,
      });
    } catch (e) {
      throw (e.toString());
    }
  }

  // remove favourite from firestore
  Future<void> removeFavourite(String productId) async {
    try {
      await firestore.collection("userFavourite").doc(productId).delete();
    } catch (e) {
      throw (e.toString());
    }
  }

  // to keep   store and load items favourite until remove from favourite
  Future<void> loadFavourites() async {
    try {
      QuerySnapshot snapshot =
          await firestore
              .collection("userFavourite")
              .where('userId', isEqualTo: userId)
              .get();
      favouriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw (e.toString());
    }
    notifyListeners();
  }
}
