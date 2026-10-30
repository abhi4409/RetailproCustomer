import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Model/category_models.dart';
import '../repository/category_repo.dart';
class CategoryViewmodel extends ChangeNotifier {
  final int categoryIndex;

  late CategoryModels _model;

  final CategoryRepository _repository = CategoryRepository();

  CategoryViewmodel({
    required this.categoryIndex,
  }) {
    _model = CategoryModels(
      selectedCategory: categoryIndex,
    );
  }

  String get searchText => _model.searchText;

  int get selectedCategory => _model.selectedCategory;

  List<String> get favoriteIds => _model.favoriteIds;

  List<String> get categories => _model.categories;

  User? get user => _repository.getCurrentUser();

  Stream<QuerySnapshot<Map<String, dynamic>>> get productStream {
    return _repository.getProducts();
  }

  void searchProduct(String value) {
    _model.searchText = value;
    notifyListeners();
  }

  void changeCategory(int index) {
    _model.selectedCategory = index;
    notifyListeners();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterProducts(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
      ) {
    return docs.where((product) {
      final data = product.data();

      final String productName =
          data['pname']?.toString().trim().toLowerCase() ?? "";

      final String productCategory =
          data['pcatogory']?.toString().trim().toLowerCase() ?? "";

      final String search = _model.searchText.trim().toLowerCase();

      if (_model.selectedCategory == 0) {
        return productName.contains(search);
      } else {
        final String selected =
        _model.categories[_model.selectedCategory].trim().toLowerCase();

        return productCategory == selected && productName.contains(search);
      }
    }).toList();
  }

  Future<void> addToCart(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snap,
      ) async {
    final user = _repository.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please login first"),
        ),
      );
      return;
    }

    final String uid = user.uid;

    final check = await _repository.checkCart(
      uid,
      snap.id,
    );

    if (check.docs.isNotEmpty) {
      final item = check.docs.first;
      final data = item.data();

      final int oldQty =
          int.tryParse(data['qty']?.toString() ?? '0') ?? 0;

      final int newQty = oldQty + 1;

      await _repository.updateCartQty(
        item.id,
        newQty,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quantity increased"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final data = snap.data();

      await _repository.addCart({
        'uid': uid,
        'productId': snap.id,
        'pname': data['pname'],
        'price': data['pselling price'],
        'pcatogory': data['pcatogory'],
        'unit': data['punits'],
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
  }

  Future<void> addFavorite(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> snap,
      ) async {
    final user = _repository.getCurrentUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please login first"),
        ),
      );
      return;
    }

    final String uid = user.uid;

    final check = await _repository.checkFavorite(
      uid,
      snap.id,
    );

    if (check.docs.isNotEmpty) {
      if (!_model.favoriteIds.contains(snap.id)) {
        _model.favoriteIds.add(snap.id);
        notifyListeners();
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Already added to favorites"),
        ),
      );
    } else {
      final data = snap.data();

      await _repository.addFavorite({
        'uid': uid,
        'productId': snap.id,
        'pname': data['pname'],
        'pcatogory': data['pcatogory'],
        'price': data['pselling price'],
      });

      _model.favoriteIds.add(snap.id);
      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added to favorites"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}