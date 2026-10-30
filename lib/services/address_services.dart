import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressServices {
  final CollectionReference<Map<String, dynamic>> addresses =
  FirebaseFirestore.instance.collection(
    'addresses',
  );

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> addressStream(
      String uid,
      ) {
    return addresses
        .where(
      'uid',
      isEqualTo: uid,
    )
        .snapshots();
  }
  Future<QuerySnapshot<Map<String, dynamic>>> getUserAddresses(
      String uid,
      ) async {
    return await addresses
        .where(
      'uid',
      isEqualTo: uid,
    )
        .get();
  }
  Future<void> addAddress(
      Map<String, dynamic> data,
      ) async {
    await addresses.add(
      data,
    );
  }
  Future<void> updateAddress(
      String id,
      Map<String, dynamic> data,
      ) async {
    await addresses
        .doc(id)
        .update(
      data,
    );
  }
  Future<void> deleteAddress(
      String id,
      ) async {
    await addresses
        .doc(id)
        .delete();
  }
  Future<void> removeDefault(
      String id,
      ) async {
    await addresses
        .doc(id)
        .update({
      'isDefault': false,
    });
  }
  Future<void> makeDefault(
      String id,
      ) async {
    await addresses
        .doc(id)
        .update({
      'isDefault': true,
    });
  }
}