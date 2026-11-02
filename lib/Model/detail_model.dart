class DetailModels {
  final dynamic snap;
  double qty;
  bool isAdding;

  DetailModels({
    required this.snap,
    this.qty = 1.0,
    this.isAdding = false,
  });
}