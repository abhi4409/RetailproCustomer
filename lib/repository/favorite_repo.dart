import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/favorite_service.dart';
class FavoriteRepository {
  final FavoriteServices _services = FavoriteServices();

  User? getCurrentUser() {
    return _services.getCurrentUser();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> favoriteStream(String uid) {
    return _services.favoriteStream(uid);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkFavorite(
      String uid,
      String productId,
      ) async {
    return await _services.checkFavorite(uid, productId);
  }

  Future<void> addFavorite(Map<String, dynamic> data) async {
    await _services.addFavorite(data);
  }

  Future<void> removeFavorite(String id) async {
    await _services.removeFavorite(id);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(
      String productId,
      ) async {
    return await _services.getProduct(productId);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkCart(
      String uid,
      String productId,
      ) async {
    return await _services.checkCart(uid, productId);
  }

  Future<void> updateCartQty(String id, int qty) async {
    await _services.updateCartQty(id, qty);
  }

  Future<void> addCart(Map<String, dynamic> data) async {
    await _services.addCart(data);
  }
}