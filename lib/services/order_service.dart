import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderServices {
  final CollectionReference<Map<String, dynamic>> cart =
  FirebaseFirestore.instance.collection('cart');

  final CollectionReference<Map<String, dynamic>> orders =
  FirebaseFirestore.instance.collection('orders');

  final CollectionReference<Map<String, dynamic>> addresses =
  FirebaseFirestore.instance.collection('addresses');

  final CollectionReference<Map<String, dynamic>> details =
  FirebaseFirestore.instance.collection('userdata');

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> cartStream(String uid) {
    return cart.where('uid', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> orderStream(String uid) {
    return orders.where('uid', isEqualTo: uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> orderDetailsStream(
      String orderId,
      ) {
    return orders.doc(orderId).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAddresses(String uid) async {
    return await addresses.where('uid', isEqualTo: uid).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCustomerDetails(
      String email,
      ) async {
    return await details.where('email', isEqualTo: email).get();
  }

  Future<void> createOrder(Map<String, dynamic> data) async {
    var ref = orders.doc();

    String orderNo = "OD-${ref.id.substring(0, 6).toUpperCase()}";

    data['orderNo'] = orderNo;
    data['date'] = FieldValue.serverTimestamp();

    await ref.set(data);
  }

  Future<void> updateCartQty(String id, int qty) async {
    await cart.doc(id).update({
      'qty': qty,
    });
  }

  Future<void> deleteCartItem(String id) async {
    await cart.doc(id).delete();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCart(String uid) async {
    return await cart.where('uid', isEqualTo: uid).get();
  }
}