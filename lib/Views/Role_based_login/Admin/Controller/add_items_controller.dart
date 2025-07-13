import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Views/Role_based_login/Admin/Model/add_items_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final additemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((
  ref,
) {
  return AddItemNotifier();
});

class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(AddItemState()) {
    fetchCategory();
  }

  final CollectionReference items = FirebaseFirestore.instance.collection(
    "items",
  );
  final CollectionReference categoriesCollection = FirebaseFirestore.instance
      .collection("category");

  // Pick image from gallery
  void pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        state = state.copyWith(imagePath: pickedFile.path);
      }
    } catch (e) {
      throw Exception("Error picking image: $e");
    }
  }

  // Select category
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  // Sizes
  void addSize(String size) {
    if (!state.sizes.contains(size)) {
      state = state.copyWith(sizes: [...state.sizes, size]);
    }
  }

  void removeSize(String size) {
    state = state.copyWith(sizes: state.sizes.where((s) => s != size).toList());
  }

  // Colors
  void addColor(String color) {
    if (!state.colors.contains(color)) {
      state = state.copyWith(colors: [...state.colors, color]);
    }
  }

  void removeColor(String color) {
    state = state.copyWith(
      colors: state.colors.where((c) => c != color).toList(),
    );
  }

  // Discount
  void toggleDiscount(bool? isDiscounted) {
    state = state.copyWith(isDiscounted: isDiscounted ?? false);
  }

  void setDiscountPercentage(String percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  // Loading
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // Fetch categories
  Future<void> fetchCategory() async {
    try {
      final snapshot = await categoriesCollection.get();
      final categories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
  }

  // upload and save items

  Future<void> uploadAndSaveItems(String name, String price) async {
    if (name.isEmpty ||
        price.isEmpty ||
        state.imagePath == null ||
        state.selectedCategory == null ||
        state.sizes.isEmpty ||
        state.colors.isEmpty ||
        (state.isDiscounted &&
            (state.discountPercentage == null ||
                state.discountPercentage!.isEmpty))) {
      throw Exception("Please fill all the fields and upload image");
    }

    setLoading(true);
    try {
      final imageFile = File(state.imagePath!);

      if (!imageFile.existsSync()) {
        throw Exception("Image file not found at path: ${state.imagePath}");
      }

      // 🔁 Upload to Cloudinary
      final imageUrl = await uploadToCloudinary(imageFile);

      if (imageUrl == null) {
        throw Exception("Cloudinary upload failed.");
      }

      // 🔁 Upload form data to Firebase Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
      await items.add({
        'name': name,
        'price': int.tryParse(price) ?? 0,
        'image': imageUrl,
        'uploadedBy': uid,
        'category': state.selectedCategory,
        'size': state.sizes,
        'color': state.colors,
        'isDiscounted': state.isDiscounted,
        'discountedPercentage':
            state.isDiscounted
                ? int.tryParse(state.discountPercentage!) ?? 0
                : 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      state = AddItemState(); // reset form
      await fetchCategory();
    } catch (e) {
      throw Exception("Error saving item: $e");
    } finally {
      setLoading(false);
    }
  }

  Future<String?> uploadToCloudinary(File file) async {
    String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      print("Cloudinary credentials not set.");
      return null;
    }

    var uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    var request = http.MultipartRequest("POST", uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['upload_preset'] = uploadPreset;

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['secure_url']; // ✅ Cloudinary image URL
    } else {
      print("Upload failed: $responseBody");
      return null;
    }
  }

  // Upload image and save item to Firestore
  // Future<void> uploadAndSaveItems(String name, String price) async {
  //   if (name.isEmpty ||
  //       price.isEmpty ||
  //       state.imagePath == null ||
  //       state.selectedCategory == null ||
  //       state.sizes.isEmpty ||
  //       state.colors.isEmpty ||
  //       (state.isDiscounted &&
  //           (state.discountPercentage == null ||
  //               state.discountPercentage!.isEmpty))) {
  //     throw Exception("Please fill all the fields and upload image");
  //   }

  //   setLoading(true);
  //   try {
  //     //new added for testng
  //     final imageFile = File(state.imagePath!);

  //     if (!imageFile.existsSync()) {
  //       throw Exception(
  //         "Selected image file not found at path: ${state.imagePath}",
  //       );
  //     }

  //     print("Uploading file from: ${state.imagePath}");
  //     print("Uploading to Firebase Storage...");
  //     //

  //     final fileName = DateTime.now().microsecondsSinceEpoch.toString();
  //     final reference = FirebaseStorage.instance.ref().child(
  //       'images/$fileName.jpg',
  //     );
  //     await reference.putFile(File(state.imagePath!));
  //     final imageUrl = await reference.getDownloadURL();

  //     final uid = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
  //     await items.add({
  //       'name': name,
  //       'price': int.tryParse(price) ?? 0,
  //       'image': imageUrl,
  //       'uploadedBy': uid,
  //       'category': state.selectedCategory,
  //       'size': state.sizes,
  //       'color': state.colors,
  //       'isDiscounted': state.isDiscounted,
  //       'discountedPercentage':
  //           state.isDiscounted
  //               ? int.tryParse(state.discountPercentage!) ?? 0
  //               : 0,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //     print("Uploading file from1: ${state.imagePath}");
  //     print("Uploading to Firebase Storage1...");
  //     // Reset state
  //     state = AddItemState();
  //   } catch (e) {
  //     throw Exception("Error saving item: $e");
  //   } finally {
  //     setLoading(false);
  //   }
  // }
}
