import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeServices {
  final CollectionReference<Map<String, dynamic>> products =
  FirebaseFirestore.instance.collection('productsdata');

  final CollectionReference<Map<String, dynamic>> favorites =
  FirebaseFirestore.instance.collection('favorites');

  final CollectionReference<Map<String, dynamic>> cart =
  FirebaseFirestore.instance.collection('cart');

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    return products.snapshots();
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

  Future<void> updateCartQty(
      String id,
      int qty,
      ) async {
    await cart.doc(id).update({
      'qty': qty,
    });
  }

  Future<void> addCart(
      Map<String, dynamic> data,
      ) async {
    await cart.add(data);
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

  Future<void> addFavorite(
      Map<String, dynamic> data,
      ) async {
    await favorites.add(data);
  }
}