import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftmart/Views/Role_based_login/Admin/Controller/add_items_controller.dart';
import 'package:swiftmart/Widgets/my__button.dart';
import 'package:swiftmart/Widgets/show_snackbar.dart';

class AddItems extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController discountPercentageController =
      TextEditingController();
  AddItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(additemProvider);
    final notifier = ref.read(additemProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add New Items"),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      state.imagePath != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(state.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                          : state.isLoading
                          ? CircularProgressIndicator()
                          : GestureDetector(
                            onTap: notifier.pickImage,
                            child: Icon(Icons.camera_alt, size: 30),
                          ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: state.selectedCategory,
                decoration: InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
                onChanged:
                    state.categories.isEmpty
                        ? null
                        : notifier.setSelectedCategory,
                items:
                    state.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
              ),
              SizedBox(height: 10),

              TextField(
                controller: sizeController,
                decoration: InputDecoration(
                  labelText: "Sizes (comma separated)",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.addSize(value);
                  sizeController.clear();
                },
              ),

              Wrap(
                spacing: 8,
                children:
                    state.sizes
                        .map(
                          (size) => Chip(
                            onDeleted: () => notifier.removeSize(size),
                            label: Text(size),
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: colorController,
                decoration: InputDecoration(
                  labelText: "Color (comma separated)",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.addColor(value);
                  colorController.clear();
                },
              ),
              Wrap(
                spacing: 8,
                children:
                    state.colors
                        .map(
                          (color) => Chip(
                            onDeleted: () => notifier.removeColor(color),
                            label: Text(color),
                          ),
                        )
                        .toList(),
              ),

              Row(
                children: [
                  Checkbox(
                    value: state.isDiscounted,
                    onChanged: notifier.toggleDiscount,
                  ),
                  const Text("Apply Discount"),
                ],
              ),

              if (state.isDiscounted)
                Column(
                  children: [
                    TextField(
                      controller: discountPercentageController,
                      decoration: InputDecoration(
                        labelText: "Discount Percentage",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        notifier.setDiscountPercentage(value);
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                    child: MyButton(
                      onTab: () async {
                        try {
                          await notifier.uploadAndSaveItems(
                            nameController.text,
                            priceController.text,
                          );
                          showSnackbar(context, "Items added successfully");
                          Navigator.of(context).pop();
                        } catch (e) {
                          showSnackbar(context, "Error: $e");
                        }
                      },
                      buttonText: "Save item",
                    ),
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
