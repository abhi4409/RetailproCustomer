import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/order_model.dart';
import '../repository/order_repo.dart';

class OrderViewmodel extends ChangeNotifier {
  final OrderModels _model = OrderModels();
  final OrderRepository _repository = OrderRepository();

  String get address => _model.address;
  String get customerName => _model.customerName;
  String get customerPhone => _model.customerPhone;
  String get paymentMethod => _model.paymentMethod;
  User? get user => _repository.getCurrentUser();

  Future<void> loadOrderData() async {
    await getAddress();
    await getCustomerDetails();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> cartStream(String uid) {
    return _repository.cartStream(uid);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> orderStream(String uid) {
    return _repository.orderStream(uid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> orderDetailsStream(
      String orderId,
      ) {
    return _repository.orderDetailsStream(orderId);
  }

  Future<void> getAddress() async {
    final currentUser = _repository.getCurrentUser();
    if (currentUser == null) return;

    final data = await _repository.getAddresses(currentUser.uid);

    if (data.docs.isEmpty) {
      _model.address = "Add delivery address";
      notifyListeners();
      return;
    }

    var selectedAddress = data.docs.first;

    for (final item in data.docs) {
      final addressData = item.data();
      if (addressData['isDefault'] == true) {
        selectedAddress = item;
        break;
      }
    }

    final addressData = selectedAddress.data();
    final String savedAddress = addressData['address']?.toString() ?? "";
    final String city = addressData['city']?.toString() ?? "";

    _model.address = "$savedAddress, $city";
    notifyListeners();
  }

  Future<void> getCustomerDetails() async {
    final currentUser = _repository.getCurrentUser();
    if (currentUser == null) return;

    final String userEmail = currentUser.email ?? "";
    if (userEmail.isEmpty) return;

    final data = await _repository.getCustomerDetails(userEmail);

    if (data.docs.isNotEmpty) {
      final customer = data.docs.first.data();
      _model.customerName = customer['name']?.toString() ?? "";
      _model.customerPhone = customer['phone']?.toString() ?? "";
      notifyListeners();
    }
  }

  void changePayment(String value) {
    _model.paymentMethod = value;
    notifyListeners();
  }

  double getItemsTotal(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    double itemsTotal = 0.0;

    for (final item in docs) {
      final data = item.data();
      final double price =
          double.tryParse(data['price']?.toString() ?? "0") ?? 0.0;
      final int qty = int.tryParse(data['qty']?.toString() ?? "0") ?? 0;

      itemsTotal += (price * qty);
    }

    return itemsTotal;
  }

  double getDeliveryCharge(List docs) {
    if (docs.isEmpty) return 0.0;
    return 30.0;
  }

  double getTotalAmount(double itemsTotal, double deliveryCharge) {
    return itemsTotal + deliveryCharge;
  }

  Future<void> placeOrder(
      BuildContext context,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      double itemsTotal,
      double deliveryCharge,
      double totalAmount,
      String uid,
      ) async {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cart is empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_model.address.isEmpty ||
        _model.address == "Add delivery address") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please add delivery address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> items = [];

    for (final item in docs) {
      final data = item.data();
      items.add({
        'productId': data['productId']?.toString() ?? "",
        'pname': data['pname']?.toString() ?? "",
        'price': data['price'] ?? 0,
        'qty': data['qty'] ?? 1,
        'unit': data['unit']?.toString() ?? "",
      });
    }

    await _repository.createOrder({
      'uid': uid,
      'customerName': _model.customerName,
      'customerPhone': _model.customerPhone,
      'items': items,
      'itemsTotal': itemsTotal,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'address': _model.address,
      'paymentMethod': _model.paymentMethod,
      'status': 'Order Placed',
    });

    await clearCart(uid);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order placed successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> increaseQty(
      QueryDocumentSnapshot<Map<String, dynamic>> snap,
      ) async {
    final data = snap.data();
    final int qty = int.tryParse(data['qty']?.toString() ?? "0") ?? 0;

    await _repository.updateCartQty(snap.id, qty + 1);
  }

  Future<void> decreaseQty(
      QueryDocumentSnapshot<Map<String, dynamic>> snap,
      ) async {
    final data = snap.data();
    final int qty = int.tryParse(data['qty']?.toString() ?? "0") ?? 0;

    if (qty > 1) {
      await _repository.updateCartQty(snap.id, qty - 1);
    }
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteCartItem(id);
  }

  Future<void> clearCart(String uid) async {
    final data = await _repository.getCart(uid);

    for (final item in data.docs) {
      await _repository.deleteCartItem(item.id);
    }
  }

  String getDate(dynamic value) {
    if (value == null) return "";

    if (value is Timestamp) {
      final DateTime date = value.toDate();
      const List<String> months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];

      return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
    }

    return value.toString();
  }

  bool placed(String status) {
    return status == "Order Placed" ||
        status == "Accepted" ||
        status == "Ready" ||
        status == "Completed" ||
        status == "Rejected";
  }

  bool accepted(String status) {
    return status == "Accepted" ||
        status == "Ready" ||
        status == "Completed";
  }

  bool ready(String status) {
    return status == "Ready" || status == "Completed";
  }

  bool completed(String status) {
    return status == "Completed";
  }
}