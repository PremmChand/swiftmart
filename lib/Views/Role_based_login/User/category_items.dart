import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swiftmart/Model/category_model.dart';
import 'package:swiftmart/Model/sub_category.dart';
import 'package:swiftmart/Provider/favourite_provider.dart';
import 'package:swiftmart/Common/Utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swiftmart/Views/Role_based_login/User/item_detail_screen.dart';

class CategoryItems extends ConsumerStatefulWidget {
  final String selectedCategory;
  final String category;
  //final List<AppModel> categoryItems;

  const CategoryItems({
    super.key,
    required this.category,
    required this.selectedCategory,
  });

  @override
  ConsumerState<CategoryItems> createState() => _CategoryItemsState();
}

class _CategoryItemsState extends ConsumerState<CategoryItems> {
  Map<String, Map<String, dynamic>> randomValueCache = {};
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allItems = [];
  List<QueryDocumentSnapshot> filteredItems = [];

  @override
  void initState() {
    searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchItem = searchController.text.toLowerCase();
    setState(() {
      filteredItems =
          allItems.where((item) {
            final data = item.data() as Map<String, dynamic>;
            final itemName = data['name'].toString().toLowerCase();
            return itemName.contains(searchItem);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference itemsCollection = FirebaseFirestore.instance
        .collection("items");
    Size size = MediaQuery.of(context).size;
    final provider = ref.watch(favouriteProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          hintText: "$category's Fashion",
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: fbackgroundColor2,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            color: Colors.black38,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    filterCategory.length,
                    (index) => Padding(
                      padding: EdgeInsets.all(5),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                filterCategory[index],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 5),
                            index == 0
                                ? Icon(Icons.filter_list, size: 15)
                                : Icon(Icons.keyboard_arrow_down, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  subCategory.length,
                  (index) => InkWell(
                    onTap: () {
                      // Optional: Handle tap
                    },
                    borderRadius: BorderRadius.circular(50),
                    splashColor: Colors.grey.withValues(alpha: .2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors
                                      .white, // background if image doesn't cover fully
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                  spreadRadius: 1,
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage(subCategory[index].image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subCategory[index].name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // product images
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    itemsCollection
                        .where('category', isEqualTo: widget.selectedCategory)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No items found."));
                  }

                  final items = snapshot.data!.docs;

                  if (allItems.isEmpty) {
                    allItems = items;
                    filteredItems = items;
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                    itemBuilder: (context, index) {
                      final doc = filteredItems[index];
                      final item = doc.data() as Map<String, dynamic>;
                      final itemId = doc.id;
                      double price =
                          double.tryParse(item['price'].toString()) ?? 0;
                      double discount =
                          double.tryParse(
                            item['discountedPercentage'].toString(),
                          ) ??
                          0;
                      if (!randomValueCache.containsKey(itemId)) {
                        randomValueCache[itemId] = {
                          "rating":
                              "${Random().nextInt(2) + 3}.${Random().nextInt(5) + 4}",
                          "reviews": Random().nextInt(300) + 100,
                        };
                      }
                      final cachedRating = randomValueCache[itemId]!['rating'];
                      final cachedReviews =
                          randomValueCache[itemId]!['reviews'];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to itemdetail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ItemDetailScreen(productitems: doc),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: doc.id,
                              child: Container(
                                height: size.height * 0.20,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: fbackgroundColor2,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      item['image'],
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          provider.isExist(items[index])
                                              ? Colors.white
                                              : Colors.black26,
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(favouriteProvider)
                                              .toggleFavourite(items[index]);
                                        },
                                        child: Icon(
                                          provider.isExist(items[index])
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              provider.isExist(items[index])
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  const Text(
                                    "H&M",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black26,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 17,
                                  ),
                                  Text("$cachedRating"),
                                  Text(
                                    "($cachedReviews)",
                                    style: TextStyle(color: Colors.black38),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                item['name'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                  "\$ ${(price * (1 - discount / 100)).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.pink,
                                    height: 1.5,
                                  ),
                                ),
                                // Text(
                                //   "\$ ${(item['price'] * (1 - item['discountedPercentage'] / 100)).toStringAsFixed(2)}",
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.w600,
                                //     fontSize: 18,
                                //     color: Colors.pink,
                                //     height: 1.5,
                                //   ),
                                // ),
                                const SizedBox(width: 5),
                                if (item['isDiscounted'] == true)
                                  Text(
                                    "\$ ${price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.black26,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.black26,
                                    ),
                                  ),
                                // Text(
                                //   "\$ ${item['price']}.00",
                                //   style: const TextStyle(
                                //     color: Colors.black26,
                                //     decoration: TextDecoration.lineThrough,
                                //     decorationColor: Colors.black26,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
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
    );
  }
}
