import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Provider/favourite_provider.dart';
import 'package:swiftmart/Common/Utils/colors.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = ref.watch(favouriteProvider);
    return Scaffold(
      backgroundColor: fbackgroundColor2,
      appBar: AppBar(
        backgroundColor: fbackgroundColor2,
        centerTitle: true,
        title: Text("Favorite", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body:
          userId == null
              ? Center(child: Text("Please log-in to view favorite"))
              : StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection("userFavourite")
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                builder: (contex, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final favoriteDocs = snapshot.data!.docs;
                  if (favoriteDocs.isEmpty) {
                    return Center(child: Text("No Favorites yet"));
                  }
                  return FutureBuilder<List<DocumentSnapshot>>(
                    future: Future.wait(
                      favoriteDocs.map(
                        (doc) =>
                            FirebaseFirestore.instance
                                .collection('items')
                                .doc(doc.id)
                                .get(),
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final favoriteItems =
                          snapshot.data!.where((doc) => doc.exists).toList();
                      if (favoriteItems.isEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        itemCount: favoriteItems.length,
                        itemBuilder: (context, index) {
                          final favoriteItem = favoriteItems[index];
                          return GestureDetector(
                            onTap: () {},
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 5,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: CachedNetworkImageProvider(
                                                favoriteItem['image'],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 20,
                                                ),
                                                child: Text(
                                                  favoriteItem['name'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${favoriteItem['category']} Fashion",
                                              ),
                                              Text(
                                                "\$  ${favoriteItem['price']}.00",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.pink,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 50,
                                  right: 35,
                                  child: GestureDetector(
                                    onTap: () {
                                      provider.toggleFavourite(favoriteItem);
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
