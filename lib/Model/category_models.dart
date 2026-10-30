class CategoryModels {
  String searchText;
  int selectedCategory;
  List<String> favoriteIds;

  final List<String> categories = [
    "All",
    "Grocery",
    "Beverages",
    "Snacks",
    "Dairy",
    "Bakery",
    "Fruits",
    "Vegetables",
    "Personal Care",
    "Household",
    "Others",
];
  CategoryModels({
    this.searchText = "",
    this.selectedCategory = 0,
    List<String>? favoriteIds,
  }) : favoriteIds = favoriteIds ?? [];
}