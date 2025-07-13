import 'package:flutter/material.dart';

class AppModel {
  final String name, image, description, category;
  final double rating;
  final int review, price;
  List<Color> fcolor;
  List<String> size;
  bool isCheck;

  AppModel({
    required this.name,
    required this.image,
    required this.rating,
    required this.price,
    required this.review,
    required this.fcolor,
    required this.size,
    required this.description,
    required this.isCheck,
    required this.category,
  });
}

List<AppModel> fashionEcommerceApp = [
  //id:1
  AppModel(
    name: "OverSized Fit Printed Mesh T-Shirt",
    rating: 4.9,
    image: "assets/category_image/women.jpeg",
    price: 295,
    review: 136,
    isCheck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["XS", "S", "M"],
    description: "",
  ),

  //id:2
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Men",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:3
  AppModel(
    name: "Winter Jacket",
    rating: 4.9,
    image: "assets/category_image/jacket.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Teens",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["S", "B", "X"],
    description: "",
  ),

  //id:4
  AppModel(
    name: "Baby Dress Set",
    rating: 5.8,
    image: "assets/category_image/baby1.jpeg",
    price: 319,
    review: 290,
    isCheck: true,
    category: "Baby",
    fcolor: [Colors.white, Colors.blue, Colors.white10],
    size: ["B", "S"],
    description: "",
  ),
  //id:5
  AppModel(
    name: "Casual Hoodie Dress for Kids",
    rating: 4.3,
    image: "assets/category_image/kids1.jpeg",
    price: 350,
    review: 190,
    isCheck: true,
    category: "Kids",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["M", "S", "XL"],
    description: "",
  ),

  //id:6
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/jacket.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Men",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:7
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody2.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:8
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody1.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Teens",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:9
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/women2.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Kids",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:10
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/women3.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Baby",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),

  // new added to see scroview after category selection
  //id:1
  AppModel(
    name: "OverSized Fit Printed Mesh T-Shirt",
    rating: 4.9,
    image: "assets/category_image/women.jpeg",
    price: 295,
    review: 136,
    isCheck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["XS", "S", "M"],
    description: "",
  ),

  //id:2
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Men",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:3
  AppModel(
    name: "Winter Jacket",
    rating: 4.9,
    image: "assets/category_image/jacket.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Teens",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["S", "B", "X"],
    description: "",
  ),

  //id:4
  AppModel(
    name: "Baby Dress Set",
    rating: 5.8,
    image: "assets/category_image/baby1.jpeg",
    price: 319,
    review: 290,
    isCheck: true,
    category: "Baby",
    fcolor: [Colors.white, Colors.blue, Colors.white10],
    size: ["B", "S"],
    description: "",
  ),
  //id:5
  AppModel(
    name: "Casual Hoodie Dress for Kids",
    rating: 4.3,
    image: "assets/category_image/kids1.jpeg",
    price: 350,
    review: 190,
    isCheck: true,
    category: "Kids",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["M", "S", "XL"],
    description: "",
  ),

  //id:6
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/jacket.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Men",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:7
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody2.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:8
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody1.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Teens",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:9
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/women2.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Kids",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:10
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/women3.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Baby",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),

  //id:1
 AppModel(
    name: "OverSized Fit Printed Mesh T-Shirt",
    rating: 4.9,
    image: "assets/category_image/women.jpeg",
    price: 295,
    review: 136,
    isCheck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["XS", "S", "M"],
    description: "",
  ),

  //id:2
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Men",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:3
  AppModel(
    name: "Winter Jacket",
    rating: 4.9,
    image: "assets/category_image/jacket.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Teens",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["S", "B", "X"],
    description: "",
  ),

  //id:4
  AppModel(
    name: "Baby Dress Set",
    rating: 5.8,
    image: "assets/category_image/baby1.jpeg",
    price: 319,
    review: 290,
    isCheck: true,
    category: "Baby",
    fcolor: [Colors.white, Colors.blue, Colors.white10],
    size: ["B", "S"],
    description: "",
  ),
  //id:5
  AppModel(
    name: "Casual Hoodie Dress for Kids",
    rating: 4.3,
    image: "assets/category_image/kids1.jpeg",
    price: 350,
    review: 190,
    isCheck: true,
    category: "Kids",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["M", "S", "XL"],
    description: "",
  ),

  //id:6
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/jacket.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Men",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:7
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody2.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:8
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/hoody1.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Teens",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:9
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/women2.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Kids",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  //id:10
  AppModel(
    name: "Printed Sweatshirt",
    rating: 4.9,
    image: "assets/category_image/women3.jpeg",
    price: 314,
    review: 176,
    isCheck: true,
    category: "Baby",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: ["X", "S", "Xl"],
    description: "",
  ),
  
];

const myDescription1 = "Elevate your casual wardrobe with our";
const myDescription2 =
    "Crafted from premium cotton for maximum comfort, this relaxed-fit tee features";
