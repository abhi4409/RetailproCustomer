class OrderModels {
  String address;
  String customerName;
  String customerPhone;
  String paymentMethod;

  OrderModels({
    this.address = "",
    this.customerName = "",
    this.customerPhone = "",
    this.paymentMethod = "UPI",
  });
}