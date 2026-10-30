class HomeModels {
  String searchText;
  List<String> favoriteIds;
  HomeModels({
    this.searchText = "",
    List<String>? favoriteIds,
  }) : favoriteIds = favoriteIds ?? [];
}
