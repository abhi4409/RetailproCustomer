import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/login_model.dart';
import '../repository/login_repo.dart';
import '../view/home/Bottomnavi.dart';

class LoginViewmodel extends ChangeNotifier {
  final LoginModels _model = LoginModels();
  final LoginRepository _repository = LoginRepository();

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController forgotEmail = TextEditingController();

  bool get showPassword => _model.showPassword;
  bool get loading => _model.loading;

  void passwordShow() {
    _model.showPassword = !_model.showPassword;
    notifyListeners();
  }

  void changeLoading(bool value) {
    _model.loading = value;
    notifyListeners();
  }

  Future login(BuildContext context) async {
    try {
      changeLoading(true);

      await _repository.login(
        email.text.trim(),
        pass.text.trim(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Bottamnavii(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Login failed",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      changeLoading(false);
    }
  }

  Future addUser() async {
    final data = {
      'email': email.text.trim(),
      'name': name.text,
      'phone': phone.text,
    };

    await _repository.addUser(data);
  }

  Future createAccount(BuildContext context) async {
    try {
      changeLoading(true);

      await _repository.createAccount(
        email.text.trim(),
        pass.text.trim(),
      );

      await addUser();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account created successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Account creation failed",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      changeLoading(false);
    }
  }

  Future forgotPassword(BuildContext context) async {
    try {
      String mail = forgotEmail.text.trim();

      if (!mail.contains("@")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Enter a valid email address"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      changeLoading(true);

      await _repository.forgotPassword(mail);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("The password reset link is sent to your Gmail $mail"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email is incorrect ${e.message ?? ''}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      changeLoading(false);
    }
  }
  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    name.dispose();
    phone.dispose();
    forgotEmail.dispose();
    super.dispose();
  }
}