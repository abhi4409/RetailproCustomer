import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteServices {
  final CollectionReference<Map<String, dynamic>> favorites =
  FirebaseFirestore.instance.collection('favorites');

  final CollectionReference<Map<String, dynamic>> cart =
  FirebaseFirestore.instance.collection('cart');

  final CollectionReference<Map<String, dynamic>> products =
  FirebaseFirestore.instance.collection('productsdata');
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> favoriteStream(String uid) {
    return favorites.where('uid', isEqualTo: uid).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkFavorite(
      String uid,
      String productId,
      ) async {
    return await favorites
        .where('uid', isEqualTo: uid)
        .where('productId', isEqualTo: productId)
        .get();
  }

  Future<void> addFavorite(Map<String, dynamic> data) async {
    await favorites.add(data);
  }

  Future<void> removeFavorite(String id) async {
    await favorites.doc(id).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(
      String productId,
      ) async {
    return await products.doc(productId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkCart(
      String uid,
      String productId,
      ) async {
    return await cart
        .where('uid', isEqualTo: uid)
        .where('productId', isEqualTo: productId)
        .get();
  }

  Future<void> updateCartQty(String id, int qty) async {
    await cart.doc(id).update({
      'qty': qty,
    });
  }

  Future<void> addCart(Map<String, dynamic> data) async {
    await cart.add(data);
  }
}