import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/address_services.dart';

class AddressRepository {
  final AddressServices _services = AddressServices();

  User? getCurrentUser() {
    return _services.getCurrentUser();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> addressStream(
      String uid,
      ) {
    return _services.addressStream(
      uid,
    );
  }
  Future<QuerySnapshot<Map<String, dynamic>>> getUserAddresses(
      String uid,
      ) async {
    return await _services.getUserAddresses(
      uid,
    );
  }
  Future<void> addAddress(
      Map<String, dynamic> data,
      ) async {
    await _services.addAddress(
      data,
    );
  }
  Future<void> updateAddress(
      String id,
      Map<String, dynamic> data,
      ) async {
    await _services.updateAddress(
      id,
      data,
    );
  }

  Future<void> deleteAddress(
      String id,
      ) async {
    await _services.deleteAddress(
      id,
    );
  }

  Future<void> removeDefault(
      String id,
      ) async {
    await _services.removeDefault(
      id,
    );
  }
  Future<void> makeDefault(
      String id,
      ) async {
    await _services.makeDefault(
      id,
    );
  }
}