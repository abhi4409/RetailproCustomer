import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/login_service.dart';

class LoginRepository {
  final LoginServices _services = LoginServices();
  Future<UserCredential> login(
      String email,
      String password,
      ) async {
    return await _services.login(
      email,
      password,
    );
  }
  Future<UserCredential> createAccount(
      String email,
      String password,
      ) async {
    return await _services.createAccount(
      email,
      password,
    );
  }
  Future<void> addUser(
      Map<String, dynamic> data,
      ) async {
    await _services.addUser(
      data,
    );
  }
  Future<void> forgotPassword(
      String email,
      ) async {
    await _services.forgotPassword(
      email,
    );
  }
}
