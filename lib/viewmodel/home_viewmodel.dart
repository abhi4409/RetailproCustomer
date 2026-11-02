import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/home_model.dart';
import '../repository/home_repo.dart';

class HomeViewmodel extends ChangeNotifier {
  final HomeModels _model = HomeModels();

  final HomeRepository _repository = HomeRepository();

  String get searchText => _model.searchText;

  List<String> get favoriteIds => _model.favoriteIds;

  User? get user => _repository.getCurrentUser();

  Stream<QuerySnapshot<Map<String, dynamic>>> get productStream {
    return _repository.getProducts();
  }

  void searchProduct(String value) {
    _model.searchText = value;

    notifyListeners();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterProducts(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    return docs.where((product) {
      var data = product.data();

      String productName =
          data['pname']?.toString().toLowerCase() ?? "";

      return productName.contains(
        _model.searchText.toLowerCase(),
      );
    }).toList();
  }

  bool isKgProduct(
      Map<String, dynamic> data,
      ) {
    String unit =
        data['punits']?.toString().trim().toLowerCase() ?? "";

    return unit == "kg" ||
        unit == "kgs" ||
        unit == "kilogram" ||
        unit == "kilograms";
  }

  Future<void> addToCart(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snap,
      ) async {
    var data = snap.data();

    double stockQuantity =
        double.tryParse(
          data['pquantity']?.toString() ?? '0',
        ) ??
            0.0;

    if (stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "This product is currently unavailable",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    bool kgProduct = isKgProduct(data);

    double addQuantity;

    if (kgProduct) {
      addQuantity = 0.1;
    } else {
      addQuantity = 1.0;
    }

    if (addQuantity > stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Not enough stock available",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    var user = _repository.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please login first",
          ),
        ),
      );

      return;
    }

    String uid = user.uid;

    var check = await _repository.checkCart(
      uid,
      snap.id,
    );

    if (check.docs.isNotEmpty) {
      var item = check.docs.first;

      var cartData = item.data();

      double oldQty =
          double.tryParse(
            cartData['qty']?.toString() ?? '0',
          ) ??
              0.0;

      double newQty = oldQty + addQuantity;

      newQty = double.parse(
        newQty.toStringAsFixed(1),
      );

      if (newQty > stockQuantity) {
        if (!context.mounted) {
          return;
        }

        String stockText;

        if (kgProduct) {
          stockText =
          "${stockQuantity.toStringAsFixed(1)} KG";
        } else {
          stockText =
              stockQuantity.toInt().toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Only $stockText available",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      await _repository.updateCartQty(
        item.id,
        newQty,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kgProduct
                ? "0.1 KG added to cart"
                : "Quantity increased",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _repository.addCart({
        'uid': uid,
        'productId': snap.id,
        'pname': data['pname'],
        'price': data['pselling price'],
        'pcatogory': data['pcatogory'],
        'unit': data['punits'],
        'qty': addQuantity,
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kgProduct
                ? "0.1 KG added to cart"
                : "Added to cart",
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> addFavorite(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snap,
      ) async {
    var user = _repository.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please login first",
          ),
        ),
      );

      return;
    }

    String uid = user.uid;

    var check = await _repository.checkFavorite(
      uid,
      snap.id,
    );

    if (check.docs.isNotEmpty) {
      if (!_model.favoriteIds.contains(snap.id)) {
        _model.favoriteIds.add(
          snap.id,
        );

        notifyListeners();
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Already added to favorites",
          ),
        ),
      );
    } else {
      var data = snap.data();

      await _repository.addFavorite({
        'uid': uid,
        'productId': snap.id,
        'pname': data['pname'],
        'pcatogory': data['pcatogory'],
        'price': data['pselling price'],
      });

      _model.favoriteIds.add(
        snap.id,
      );

      notifyListeners();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Added to favorites",
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}