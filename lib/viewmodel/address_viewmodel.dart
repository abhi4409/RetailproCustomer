import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/address_models.dart';
import '../repository/address_repo.dart';

class AddressViewmodel extends ChangeNotifier {
  final AddressModels _model = AddressModels();
  final AddressRepository _repository = AddressRepository();
  TextEditingController type = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  bool get setDefault => _model.setDefault;
  User? get user => _repository.getCurrentUser();
  Stream<QuerySnapshot<Map<String, dynamic>>> addressStream(
      String uid,
      ) {
    return _repository.addressStream(
      uid,
    );
  }
  Future prepareAddAddress() async {
    var currentUser =
    _repository.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    type.clear();
    name.clear();
    address.clear();
    city.clear();

    _model.setDefault =
    false;

    var check =
    await _repository.getUserAddresses(
      currentUser.uid,
    );

    if (check.docs.isEmpty) {
      _model.setDefault =
      true;
    }

    notifyListeners();
  }

  void prepareEditAddress(
      Map<String, dynamic> data,
      ) {
    type.text =
        data['type']
            ?.toString() ??
            "";

    name.text =
        data['name']
            ?.toString() ??
            "";

    address.text =
        data['address']
            ?.toString() ??
            "";

    city.text =
        data['city']
            ?.toString() ??
            "";

    _model.setDefault =
        data['isDefault'] ??
            false;

    notifyListeners();
  }

  void changeDefault(
      bool value,
      ) {
    _model.setDefault =
        value;

    notifyListeners();
  }

  Future addAddress(
      BuildContext context,
      ) async {
    var currentUser =
    _repository.getCurrentUser();

    if (currentUser == null) {
      return;
    }

    if (name.text.isEmpty ||
        address.text.isEmpty ||
        city.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Enter all address details",
          ),
        ),
      );

      return;
    }

    if (_model.setDefault) {
      var allAddress =
      await _repository
          .getUserAddresses(
        currentUser.uid,
      );

      for (var item
      in allAddress.docs) {
        await _repository
            .removeDefault(
          item.id,
        );
      }
    }

    await _repository.addAddress({
      'uid':
      currentUser.uid,

      'type':
      type.text.isEmpty
          ? "Home"
          : type.text,

      'name':
      name.text,

      'address':
      address.text,

      'city':
      city.text,

      'isDefault':
      _model.setDefault,
    });

    if (!context.mounted) {
      return;
    }

    Navigator.pop(
      context,
    );

    clearControllers();
  }

  Future updateAddress(
      BuildContext context,
      String id,
      ) async {
    var currentUser =
    _repository.getCurrentUser();
    if (currentUser == null) {
      return;
    }
    if (name.text.isEmpty ||
        address.text.isEmpty ||
        city.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Enter all address details",
          ),
        ),
      );
      return;
    }
    if (_model.setDefault) {
      var allAddress = await _repository
          .getUserAddresses(
        currentUser.uid,
      );

      for (var item
      in allAddress.docs) {
        await _repository
            .removeDefault(
          item.id,
        );
      }
    }

    await _repository.updateAddress(
      id,
      {
        'type': type.text.isEmpty
            ? "Home" : type.text,
        'name': name.text,
        'address': address.text,
        'city': city.text,
        'isDefault': _model.setDefault,
      },
    );

    if (!context.mounted) {
      return;
    }

    Navigator.pop(
      context,
    );

    clearControllers();
  }
  Future deleteAddress(
      String id,
      bool isDefault,
      ) async {
    var currentUser =
    _repository.getCurrentUser();

    if (currentUser == null) {
      return;
    }
    await _repository.deleteAddress(
      id,
    );
    if (isDefault) {
      var remaining =
      await _repository
          .getUserAddresses(
        currentUser.uid,
      );
      if (remaining.docs.isNotEmpty) {
        await _repository.makeDefault(
          remaining.docs.first.id,
        );
      }
    }
  }
  void clearControllers() {
    type.clear();
    name.clear();
    address.clear();
    city.clear();
    _model.setDefault = false;
    notifyListeners();
  }

  @override
  void dispose() {
    type.dispose();
    name.dispose();
    address.dispose();
    city.dispose();
    super.dispose();
  }
}