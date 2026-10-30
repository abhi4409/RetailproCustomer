import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/detail_services.dart';

class DetailRepository {
  final DetailServices _services =
  DetailServices();

  User? getCurrentUser() {
    return _services.getCurrentUser();
  }
  Future<QuerySnapshot<Map<String, dynamic>>> checkCart(
      String uid,
      String productId,
      ) async {
    return await _services.checkCart(
      uid,
      productId,
    );
  }
  Future<void> updateCartQuantity(
      String id,
      int qty,
      ) async {
    await _services.updateCartQuantity(
      id,
      qty,
    );
  }
  Future<void> addCart(
      Map<String, dynamic> data,
      ) async {
    await _services.addCart(
      data,
    );
  }
}