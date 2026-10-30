import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailServices {
  final CollectionReference<Map<String, dynamic>> cart =
  FirebaseFirestore.instance.collection(
    'cart',
  );

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> checkCart(
      String uid,
      String productId,
      ) async {
    return await cart
        .where(
      'uid',
      isEqualTo: uid,
    )
        .where(
      'productId',
      isEqualTo: productId,
    )
        .get();
  }
  Future<void> updateCartQuantity(
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
    await cart.add(
      data,
    );
  }
}