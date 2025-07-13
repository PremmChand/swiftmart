class Category {
  final String name, image;
  Category({required this.name, required this.image});

  @override
  String toString() => 'Category(name: $name, image: $image)';
}

List<Category> category = [
  Category(name: "Women", image: "assets/women.jpeg"),

  Category(name: "Men", image: "assets/men.jpeg"),

  Category(name: "Teens", image: "assets/teens.jpeg"),

  Category(name: "Kids", image: "assets/kids.jpeg"),

  Category(name: "Baby", image: "assets/baby.jpeg"),
];

// List<String> filterCategory = [
//   "Filter",
//   "Ratings",
//   "Size",
//   "Color",
//   "Price",
//   "Brand",
// ];
