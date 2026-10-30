import 'package:flutter/material.dart';
import '../Model/detail_model.dart';
import '../repository/detail_repo.dart';

class DetailViewmodel extends ChangeNotifier {
  late DetailModels _model;
  final DetailRepository _repository = DetailRepository();
  DetailViewmodel({
    required dynamic snap,
  }) {
    _model = DetailModels(
      snap: snap,
    );
  }

  dynamic get snap => _model.snap;

  int get qty => _model.qty;

  bool get isAdding => _model.isAdding;

  int get stockQuantity {
    return int.tryParse(
      _model.snap['pquantity']?.toString() ?? '0',
    ) ??
        0;
  }

  bool get isAvailable => stockQuantity > 0;

  void incrementQty() {
    if (_model.qty < stockQuantity) {
      _model.qty++;
      notifyListeners();
    }
  }

  void decrementQty() {
    if (_model.qty > 1) {
      _model.qty--;
      notifyListeners();
    }
  }

  Future<void> addToCart(
      BuildContext context,
      ) async {
    final user = _repository.getCurrentUser();

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

    _model.isAdding = true;
    notifyListeners();

    try {
      final String uid = user.uid;

      final check = await _repository.checkCart(
        uid,
        _model.snap.id,
      );

      if (check.docs.isNotEmpty) {
        final item = check.docs.first;
        final data = item.data();

        final int oldQty = int.tryParse(
          data['qty']?.toString() ?? '0',
        ) ??
            0;

        final int newQty = oldQty + _model.qty;

        await _repository.updateCartQuantity(
          item.id,
          newQty,
        );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Quantity updated in cart",
            ),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        await _repository.addCart({
          'uid': uid,
          'productId': _model.snap.id,
          'pname': _model.snap['pname'],
          'price': _model.snap['pselling price'],
          'pcatogory': _model.snap['pcatogory'],
          'unit': _model.snap['punits'],
          'qty': _model.qty,
        });

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Added to cart",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to add to cart: $e",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _model.isAdding = false;
      notifyListeners();
    }
  }
}