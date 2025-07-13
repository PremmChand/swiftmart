import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Provider/cart_provider.dart';
import 'package:swiftmart/Provider/favourite_provider.dart';
import 'package:swiftmart/Views/Role_based_login/Admin/Screen/add_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swiftmart/Views/Role_based_login/Admin/Screen/order_screen.dart';
import 'package:swiftmart/Views/login_screen.dart';
import 'package:swiftmart/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  final AuthService _authService = AuthService();
  final CollectionReference items = FirebaseFirestore.instance.collection(
    "items",
  );
  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  Future<void> fetchCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("category").get();
    setState(() {
      categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: Colors.blue[100],

      // appBar: AppBar(
      //   centerTitle: true,
      //   backgroundColor: Colors.white,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: const Text(""),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "Your Uploaded Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),

                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.receipt_long),
                      ),
                      Positioned(
                        top: 6,
                        right: 8,
                        child: StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection("Orders")
                                  .snapshots(),
                          builder: (
                            context,
                            AsyncSnapshot<QuerySnapshot> snapshot,
                          ) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Text("Error loading orders");
                            }
                            final orderCount = snapshot.data?.docs.length;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AdminOrderScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 9,
                                backgroundColor: Colors.red,
                                child: Center(
                                  child: Text(
                                    orderCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      _authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                      ref.invalidate(cartService);
                      ref.invalidate(favouriteProvider);
                    },
                    child: const Icon(Icons.exit_to_app),
                  ),

                  DropdownButton<String>(
                    items:
                        categories.map((String category) {
                          return DropdownMenuItem(
                            child: Text(category),
                            value: category,
                          );
                        }).toList(),
                    icon: const Icon(Icons.tune),
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream:
                      items
                          .where("uploadedBy", isEqualTo: uid)
                          .where('category', isEqualTo: selectedCategory)
                          .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading items."));
                    }
                    final document = snapshot.data?.docs ?? [];
                    if (document.isEmpty) {
                      return Center(child: Text("No items uploaded."));
                    }
                    return ListView.builder(
                      itemCount: document.length,
                      itemBuilder: (context, index) {
                        final items =
                            document[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 2,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: items['image'],
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                items['name'] ?? "N/A",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        items['price'] != null
                                            ? "\$${items['price']}.00"
                                            : "N/A",
                                        style: TextStyle(
                                          fontSize: 15,
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text("${items['category'] ?? "N/A"}"),
                                      //const SizedBox(width: 5),
                                      //Text("${items['category'] ?? "N/A"}"),
                                    ],
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => AddItems()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
