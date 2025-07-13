class AddItemState {
  final String? imagePath;
  final bool isLoading;
  final String? selectedCategory;
  final List<String> categories;
  final List<String> sizes;
  final List<String> colors;
  final bool isDiscounted;
  final String? discountPercentage;

  AddItemState({
    this.imagePath,
    this.isLoading = false,
    this.selectedCategory,
    this.categories = const [],
    this.sizes = const [],
    this.colors = const [],
    this.isDiscounted = false,
    this.discountPercentage,
  });

  AddItemState copyWith({
    final String? imagePath,
    final bool? isLoading,
    final String? selectedCategory,
    final List<String>? categories,
    final List<String>? sizes,
    final List<String>? colors,
    final bool? isDiscounted,
    final String? discountPercentage,
  }) {
    return AddItemState(
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}
