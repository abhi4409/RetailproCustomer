import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/order_service.dart';
class OrderRepository {
  final OrderServices _services = OrderServices();
  User? getCurrentUser() {
    return _services.getCurrentUser();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> cartStream(
      String uid,
      ) {
    return _services.cartStream(
      uid,
    );
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> orderStream(
      String uid,
      ) {
    return _services.orderStream(
      uid,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> orderDetailsStream(
      String orderId,
      ) {
    return _services.orderDetailsStream(
      orderId,
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAddresses(
      String uid,
      ) async {
    return await _services.getAddresses(
      uid,
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCustomerDetails(
      String email,
      ) async {
    return await _services.getCustomerDetails(
      email,
    );
  }

  Future<void> createOrder(
      Map<String, dynamic> data,
      ) async {
    await _services.createOrder(
      data,
    );
  }

  Future<void> updateCartQty(
      String id,
      int qty,
      ) async {
    await _services.updateCartQty(
      id,
      qty,
    );
  }

  Future<void> deleteCartItem(
      String id,
      ) async {
    await _services.deleteCartItem(
      id,
    );
  }
  Future<QuerySnapshot<Map<String, dynamic>>> getCart(
      String uid,
      ) async {
    return await _services.getCart(
      uid,
    );
  }
}