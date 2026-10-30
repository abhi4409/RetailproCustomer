import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final CollectionReference<Map<String, dynamic>> details =
  FirebaseFirestore.instance.collection('userdata');

  Future<UserCredential> login(
      String email,
      String password,
      ) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<UserCredential> createAccount(
      String email,
      String password,
      ) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> addUser(
      Map<String, dynamic> data,
      ) async {
    await details.add(data);
  }

  Future<void> forgotPassword(
      String email,
      ) async {
    await auth.sendPasswordResetEmail(
      email: email,
    );
  }
}