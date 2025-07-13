import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Provider/cart_provider.dart';
import 'package:swiftmart/Provider/favourite_provider.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Order/my_order_screen.dart';
import 'package:swiftmart/Views/Role_based_login/User/User%20Profile/Payment/payment_screen.dart';
import 'package:swiftmart/Views/login_screen.dart';
import 'package:swiftmart/services/auth_service.dart';

final AuthService authService = AuthService();

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text("Profile"), backgroundColor: Colors.white),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: double.maxFinite,
                child: StreamBuilder<DocumentSnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final user = snapshot.data!;
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: CachedNetworkImageProvider(
                            "https://reputationprotectiononline.com/wp-content/uploads/2022/04/78-786207_user-avatar-png-user-avatar-icon-png-transparent.png",
                          ),
                        ),
                        Text(
                          user['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            height: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: const TextStyle(height: 0.5),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyOrderScreen(),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Icon(Icons.change_circle_rounded, size: 30),
                      title: Text(
                        "Order",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Icon(Icons.payment, size: 30),
                      title: Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(Icons.info, size: 30),
                      title: Text(
                        "About Us",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                      ref.invalidate(cartService);
                      ref.invalidate(favouriteProvider);
                    },

                    child: ListTile(
                      leading: Icon(Icons.exit_to_app, size: 30),
                      title: Text(
                        "Login Out",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
