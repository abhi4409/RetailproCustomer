import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';


class ProfileRepository {
  final ProfileServices _services = ProfileServices();

  User? getCurrentUser() {
    return _services.getCurrentUser();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserByEmail(
      String email,
      ) async {
    return await _services.getUserByEmail(email);
  }

  Future<void> updateUser(
      String id,
      Map<String, dynamic> data,
      ) async {
    await _services.updateUser(id, data);
  }

  Future<String> addUser(
      Map<String, dynamic> data,
      ) async {
    return await _services.addUser(data);
  }

  Future<XFile?> pickImage() async {
    return await _services.pickImage();
  }

  Future<String> uploadProfileImage(
      String path,
      Uint8List bytes,
      ) async {
    return await _services.uploadProfileImage(path, bytes);
  }

  Future<void> changePassword(
      String currentPassword,
      String newPassword,
      ) async {
    await _services.changePassword(
      currentPassword,
      newPassword,
    );
  }

  Future<void> signOut() async {
    await _services.signOut();
  }
}