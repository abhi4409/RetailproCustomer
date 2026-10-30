import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/category_services.dart';
class CategoryRepository {
  final CategoryServices _services = CategoryServices();

  User? getCurrentUser() {
    return _services.getCurrentUser();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    return _services.getProducts();
  }
  Future<QuerySnapshot<Map<String, dynamic>>> checkCart(
      String uid,
      String productId,
      ) async {
    return await _services.checkCart(uid, productId);
  }
  Future<void> updateCartQty(
      String id,
      int qty,
      ) async {
    await _services.updateCartQty(id, qty);
  }

  Future<void> addCart(
      Map<String, dynamic> data,
      ) async {
    await _services.addCart(data);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkFavorite(
      String uid,
      String productId,
      ) async {
    return await _services.checkFavorite(uid, productId);
  }

  Future<void> addFavorite(
      Map<String, dynamic> data,
      ) async {
    await _services.addFavorite(data);
  }
}