

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swiftmart/Common/Utils/cart_order_count.dart';
import 'package:swiftmart/Model/category_model.dart';
import 'package:swiftmart/Views/Role_based_login/User/category_items.dart';
import 'package:swiftmart/Views/Role_based_login/User/item_detail_screen.dart';
import 'package:swiftmart/Widgets/banner.dart';
import 'package:swiftmart/Views/Role_based_login/User/curated_items.dart';
import 'package:swiftmart/Common/Utils/colors.dart';

class AppHomeScreen extends StatefulWidget {
  const AppHomeScreen({super.key});

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  //for category collectionn
  final CollectionReference categoriesItems = FirebaseFirestore.instance
      .collection("category");

  //for ecommerce item colllection
  final CollectionReference items = FirebaseFirestore.instance.collection(
    "items",
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/cartt.jpeg", height: 40, width: 80,),
                  
                   CartOrderCount(),
                  // Stack(
                  //   clipBehavior: Clip.none,
                  //   children: [
                  //     Icon(Iconsax.shopping_bag, size: 28),
                  //     Positioned(
                  //       right: -3,
                  //       top: -5,
                  //       child: Container(
                  //         padding: EdgeInsets.all(4),
                  //         decoration: BoxDecoration(
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
                ],
              ),
            ),
           
            SizedBox(height: 20),
            MyBanner(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shop By Category",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            //for category
            StreamBuilder(
              stream: categoriesItems.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        streamSnapshot.data!.docs.length, //category.length,
                        (index) => InkWell(
                          onTap: () {
                            // navigate to the categoryitems screen with the filtered items
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CategoryItems(
                                      selectedCategory:
                                          streamSnapshot
                                              .data!
                                              .docs[index]['name'],
                                      category:
                                          streamSnapshot
                                              .data!
                                              .docs[index]['name'],
                                      // category: category[index].name,
                                      //: filterItems,
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: fbackgroundColor1,
                                  backgroundImage: AssetImage(
                                    category[index].image,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                category[index].name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            //for curated
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Curated For You",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            //for curated items
            StreamBuilder(
              stream: items.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(snapshot.data!.docs.length, (
                        index,
                      ) {
                        final eCommerceItems = snapshot.data!.docs[index];
                        return Padding(
                          padding:
                              index == 0
                                  ? EdgeInsets.symmetric(horizontal: 20)
                                  : EdgeInsets.only(right: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ItemDetailScreen(
                                        productitems: eCommerceItems,
                                      ),
                                ),
                              );
                            },
                            child: CuratedItems(
                              eCommerceItems: eCommerceItems,
                              size: size,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
