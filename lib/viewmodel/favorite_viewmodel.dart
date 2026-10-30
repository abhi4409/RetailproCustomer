import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/favorite_mode.dart';
import '../repository/favorite_repo.dart';
class FavoriteViewmodel extends ChangeNotifier {
  final FavoriteModels _model = FavoriteModels();
  final FavoriteRepository _repository = FavoriteRepository();

  String get searchText => _model.searchText;
  User? get user => _repository.getCurrentUser();
  Stream<QuerySnapshot<Map<String, dynamic>>> favoriteStream(String uid) {
    return _repository.favoriteStream(uid);
  }
  void searchFavorite(String value) {
    _model.searchText = value;
    notifyListeners();
  }
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterFavorites(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    if (_model.searchText.isEmpty) {
      return docs;
    }
    return docs.where((doc) {
      var data = doc.data();
      String name = data['pname']?.toString().toLowerCase() ?? "";
      return name.contains(_model.searchText.toLowerCase());
    }).toList();
  }
  Future addFavorite(dynamic snap, BuildContext context) async {
    User? currentUser = _repository.getCurrentUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please login first"),
        ),
      );
      return;
    }

    String uid = currentUser.uid;

    var check = await _repository.checkFavorite(uid, snap.id);

    if (check.docs.isNotEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Already added to favorites"),
        ),
      );
      return;
    }

    var data = snap.data() as Map<String, dynamic>;

    await _repository.addFavorite({
      'uid': uid,
      'productId': snap.id,
      'pname': data['pname']?.toString() ?? "",
      'pcatogory': data['pcatogory']?.toString() ?? "",
      'price': data['pselling price']?.toString() ?? "0",
      'unit': data['punits']?.toString() ?? "",
      'mrp': data['pmrp']?.toString() ?? "0",
      'pimage': data['pimage']?.toString() ?? "",
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added to favorites"),
        backgroundColor: Colors.green,
      ),
    );

    notifyListeners();
  }

  Future removeFavorite(String id) async {
    await _repository.removeFavorite(id);
    notifyListeners();
  }

  Future<String> getProductImage(Map<String, dynamic> favoriteData) async {
    String image = favoriteData['pimage']?.toString() ?? "";
    if (image.isNotEmpty) {
      return image;
    }

    String productId = favoriteData['productId']?.toString() ?? "";
    if (productId.isEmpty) {
      return "";
    }

    var product = await _repository.getProduct(productId);
    if (!product.exists) {
      return "";
    }

    var productData = product.data();
    if (productData == null) {
      return "";
    }

    return productData['pimage']?.toString() ?? "";
  }

  Future addToCart(dynamic favoriteSnap, BuildContext context) async {
    User? currentUser = _repository.getCurrentUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please login first"),
        ),
      );
      return;
    }

    String uid = currentUser.uid;
    var favoriteData = favoriteSnap.data() as Map<String, dynamic>;
    String productId = favoriteData['productId']?.toString() ?? "";

    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product not found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var product = await _repository.getProduct(productId);

    if (!product.exists) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product not available"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var productData = product.data();
    if (productData == null) {
      return;
    }

    int stock = int.tryParse(productData['pquantity']?.toString() ?? "0") ?? 0;

    if (stock <= 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product is out of stock"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var check = await _repository.checkCart(uid, productId);

    if (check.docs.isNotEmpty) {
      var cartItem = check.docs.first;
      var cartData = cartItem.data();

      int oldQty = int.tryParse(cartData['qty']?.toString() ?? "1") ?? 1;

      if (oldQty >= stock) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Only $stock items available"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      int newQty = oldQty + 1;

      await _repository.updateCartQty(cartItem.id, newQty);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quantity increased"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _repository.addCart({
        'uid': uid,
        'productId': productId,
        'pname': productData['pname']?.toString() ?? "",
        'price': productData['pselling price']?.toString() ?? "0",
        'pcatogory': productData['pcatogory']?.toString() ?? "",
        'unit': productData['punits']?.toString() ?? "",
        'mrp': productData['pmrp']?.toString() ?? "0",
        'pimage': productData['pimage']?.toString() ?? "",
        'qty': 1,
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added to cart"),
          backgroundColor: Colors.green,
        ),
      );
    }

    notifyListeners();
  }
}