import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ProfileServices {
  final CollectionReference<Map<String, dynamic>> details =
  FirebaseFirestore.instance.collection('userdata');

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserByEmail(
      String email,
      ) async {
    return await details
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
  }

  Future<void> updateUser(
      String id,
      Map<String, dynamic> data,
      ) async {
    await details.doc(id).update(data);
  }

  Future<String> addUser(
      Map<String, dynamic> data,
      ) async {
    final newData = await details.add(data);
    return newData.id;
  }

  Future<XFile?> pickImage() async {
    return await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
  }

  Future<String> uploadProfileImage(
      String path,
      Uint8List bytes,
      ) async {
    final supabase = Supabase.instance.client;

    await supabase.storage.from('Produtimages').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: false),
    );

    return supabase.storage.from('Produtimages').getPublicUrl(path);
  }

  Future<void> changePassword(
      String currentPassword,
      String newPassword,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      return;
    }

    final AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}