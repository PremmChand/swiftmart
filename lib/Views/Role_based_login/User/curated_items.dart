import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Provider/favourite_provider.dart';

class CuratedItems extends ConsumerWidget {
  //final AppModel eCommerceItems;
  final DocumentSnapshot<Object?> eCommerceItems;
  final Size size;
  const CuratedItems({
    super.key,
    required this.eCommerceItems,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double price = double.tryParse(eCommerceItems['price'].toString()) ?? 0;
    double discount =
        double.tryParse(eCommerceItems['discountedPercentage'].toString()) ?? 0;
    bool isDiscounted = eCommerceItems['isDiscounted'] == true;

    final provider = ref.watch(favouriteProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: eCommerceItems.id,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(eCommerceItems['image']),
              ),
            ),
            height: size.height * 0.25,
            width: size.width * 0.5,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topRight,
                child: 
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      provider.isExist(eCommerceItems)
                          ? Colors.white
                          : Colors.black26,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(favouriteProvider)
                          .toggleFavourite(eCommerceItems);
                    },
                    child: Icon(
                      provider.isExist(eCommerceItems)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          provider.isExist(eCommerceItems)
                              ? Colors.red
                              : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 7),
        Row(
          // mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "H&M",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black26,
              ),
            ),
            SizedBox(height: 7),
            Icon(Icons.star, color: Colors.amber, size: 17),
            Text("${Random().nextInt(2) + 3} .${Random().nextInt(5) + 4}"),
            Text(
              "(${Random().nextInt(300) + 25})",
              style: TextStyle(color: Colors.black26),
            ),
          ],
        ),
        SizedBox(
          width: size.width * 0.5,
          child: Text(
            eCommerceItems['name'] ?? "N/A",
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
              //"\$ ${(eCommerceItems['price'] * (1 - eCommerceItems['discountedPercentage'] / 100)).toStringAsFixed(2)}",
              "\$ ${(price * (1 - discount / 100)).toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.pink,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 5),
            if (eCommerceItems['isDiscounted'] == true)
              Text(
                // "\$ ${eCommerceItems['price'] + 255}.00",
                "\$ ${(price).toStringAsFixed(2)}",

                style: const TextStyle(
                  color: Colors.black26,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.black26,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
