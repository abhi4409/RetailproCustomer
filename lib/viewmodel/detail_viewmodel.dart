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
    if (isKgProduct) {
      _model.qty = 0.1;
    } else {
      _model.qty = 1.0;
    }
  }

  dynamic get snap => _model.snap;

  double get qty => _model.qty;

  bool get isAdding => _model.isAdding;

  double get stockQuantity {
    return double.tryParse(
      _model.snap['pquantity']?.toString() ?? '0',
    ) ??
        0.0;
  }

  String get unit {
    return _model.snap['punits']
        ?.toString()
        .trim()
        .toLowerCase() ??
        "";
  }

  bool get isKgProduct {
    return unit == "kg" ||
        unit == "kgs" ||
        unit == "kilogram" ||
        unit == "kilograms";
  }

  bool get isAvailable {
    return stockQuantity > 0;
  }

  double get quantityStep {
    if (isKgProduct) {
      return 0.1;
    }

    return 1.0;
  }

  String get displayQty {
    if (isKgProduct) {
      return qty.toStringAsFixed(1);
    }

    return qty.toInt().toString();
  }

  String get displayStock {
    if (isKgProduct) {
      return stockQuantity.toStringAsFixed(1);
    }

    return stockQuantity.toInt().toString();
  }

  void incrementQty() {
    double newQty = _model.qty + quantityStep;

    // Avoid floating point values such as 0.30000000004
    newQty = double.parse(
      newQty.toStringAsFixed(1),
    );

    if (newQty <= stockQuantity) {
      _model.qty = newQty;

      notifyListeners();
    }
  }

  void decrementQty() {
    double minimumQty;

    if (isKgProduct) {
      minimumQty = 0.1;
    } else {
      minimumQty = 1.0;
    }

    double newQty = _model.qty - quantityStep;

    newQty = double.parse(
      newQty.toStringAsFixed(1),
    );

    if (newQty >= minimumQty) {
      _model.qty = newQty;

      notifyListeners();
    }
  }

  Future<void> addToCart(
      BuildContext context,
      ) async {
    if (!isAvailable) {
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

    if (_model.qty > stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Only $displayStock ${isKgProduct ? 'KG' : ''} available",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

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

        final double oldQty =
            double.tryParse(
              data['qty']?.toString() ?? '0',
            ) ??
                0.0;

        double newQty = oldQty + _model.qty;

        newQty = double.parse(
          newQty.toStringAsFixed(1),
        );

        if (newQty > stockQuantity) {
          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Only $displayStock ${isKgProduct ? 'KG' : ''} available",
              ),
              backgroundColor: Colors.red,
            ),
          );

          return;
        }

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