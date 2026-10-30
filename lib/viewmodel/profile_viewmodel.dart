import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/profile_model.dart';
import '../repository/Profile_repo.dart';
import '../view/login/Login.dart';

class ProfileViewmodel extends ChangeNotifier {
  final ProfileModels _model = ProfileModels();
  final ProfileRepository _repository = ProfileRepository();

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController role = TextEditingController();
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController reenterPassword = TextEditingController();

  String get docId => _model.docId;
  bool get loading => _model.loading;
  bool get edit => _model.edit;
  bool get passwordLoading => _model.passwordLoading;
  bool get imageUploading => _model.imageUploading;
  Uint8List? get profileImage => _model.profileImage;
  String get profileImageUrl => _model.profileImageUrl;

  ProfileViewmodel() {
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      _model.loading = true;
      notifyListeners();

      final user = _repository.getCurrentUser();

      if (user == null || user.email == null) {
        _model.loading = false;
        notifyListeners();
        return;
      }

      email.text = user.email!;
      role.text = "Customer";

      final data = await _repository.getUserByEmail(user.email!);

      if (data.docs.isNotEmpty) {
        final snap = data.docs.first;
        final userData = snap.data();

        _model.docId = snap.id;
        name.text = userData['name']?.toString() ?? "";
        phone.text = userData['phone']?.toString() ?? "";
        email.text = userData['email']?.toString() ?? user.email!;
        role.text = "Customer";
        _model.profileImageUrl = userData['profileImage']?.toString() ?? "";
      }

      _model.loading = false;
      notifyListeners();
    } catch (e) {
      _model.loading = false;
      notifyListeners();
    }
  }

  Future<void> pickProfileImage(BuildContext context) async {
    final picked = await _repository.pickImage();
    if (picked == null) return;

    final user = _repository.getCurrentUser();
    if (user == null) return;

    try {
      _model.imageUploading = true;
      notifyListeners();

      final Uint8List bytes = await picked.readAsBytes();
      _model.profileImage = bytes;

      String extension = "jpg";
      if (picked.name.contains('.')) {
        extension = picked.name.split('.').last.toLowerCase();
      }

      final String fileName =
          "${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension";
      final String path = "profiles/$fileName";

      final String imageUrl = await _repository.uploadProfileImage(
        path,
        bytes,
      );

      _model.profileImageUrl = imageUrl;

      if (_model.docId.isNotEmpty) {
        await _repository.updateUser(
          _model.docId,
          {'profileImage': imageUrl},
        );
      } else {
        if (user.email == null) return;

        final check = await _repository.getUserByEmail(user.email!);

        if (check.docs.isNotEmpty) {
          _model.docId = check.docs.first.id;
          await _repository.updateUser(
            _model.docId,
            {'profileImage': imageUrl},
          );
        } else {
          _model.docId = await _repository.addUser({
            'name': name.text,
            'phone': phone.text,
            'email': user.email ?? "",
            'profileImage': imageUrl,
          });
        }
      }

      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image upload failed $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _model.imageUploading = false;
      notifyListeners();
    }
  }

  void enableEdit() {
    _model.edit = true;
    notifyListeners();
  }

  Future<void> updateProfile(BuildContext context) async {
    final user = _repository.getCurrentUser();
    if (user == null) return;

    try {
      final Map<String, dynamic> data = {
        'name': name.text,
        'phone': phone.text,
        'email': user.email ?? "",
        'profileImage': _model.profileImageUrl,
      };

      if (_model.docId.isNotEmpty) {
        await _repository.updateUser(_model.docId, data);
      } else if (user.email != null) {
        final check = await _repository.getUserByEmail(user.email!);

        if (check.docs.isNotEmpty) {
          _model.docId = check.docs.first.id;
          await _repository.updateUser(_model.docId, data);
        } else {
          _model.docId = await _repository.addUser(data);
        }
      }

      _model.edit = false;
      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile update failed $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> changePassword(BuildContext context) async {
    if (currentPassword.text.isEmpty ||
        newPassword.text.isEmpty ||
        reenterPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter all password fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.text != reenterPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must have at least 6 characters"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      _model.passwordLoading = true;
      notifyListeners();

      await _repository.changePassword(
        currentPassword.text,
        newPassword.text,
      );

      currentPassword.clear();
      newPassword.clear();
      reenterPassword.clear();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      String message = e.message ?? "Password change failed";

      if (e.code == "wrong-password" || e.code == "invalid-credential") {
        message = "Current password is incorrect";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _model.passwordLoading = false;
      notifyListeners();
    }
  }

  Future<void> signout(BuildContext context) async {
    await _repository.signOut();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logout successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Log(),
      ),
    );
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    role.dispose();
    currentPassword.dispose();
    newPassword.dispose();
    reenterPassword.dispose();

    super.dispose();
  }
}