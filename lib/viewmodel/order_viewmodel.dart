import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repository/address_repo.dart';

class OrderViewmodel extends ChangeNotifier {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  final AddressRepository _addressRepository =
  AddressRepository();

  User? get user => auth.currentUser;

  String address = "No address selected";

  String paymentMethod = "UPI";

  bool isLoading = false;

  Future<void> loadOrderData() async {
    await getAddress();
  }

  void changePayment(String value) {
    paymentMethod = value;
    notifyListeners();
  }

  double getDouble(dynamic value) {
    return double.tryParse(
      value?.toString() ?? "0",
    ) ??
        0.0;
  }

  bool isKgProduct(dynamic unit) {
    String value =
        unit?.toString().trim().toLowerCase() ?? "";

    return value == "kg" ||
        value == "kgs" ||
        value == "kilogram" ||
        value == "kilograms";
  }

  double normalizeQty(double value) {
    return double.parse(
      value.toStringAsFixed(1),
    );
  }

  String displayQty(double value) {
    double qty =
    normalizeQty(value);

    if (qty ==
        qty.roundToDouble()) {
      return qty
          .toInt()
          .toString();
    }

    return qty.toStringAsFixed(1);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
  cartStream(
      String uid,
      ) {
    return firestore
        .collection('cart')
        .where(
      'uid',
      isEqualTo: uid,
    )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
  orderStream(
      String uid,
      ) {
    return firestore
        .collection('orders')
        .where(
      'uid',
      isEqualTo: uid,
    )
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>
  orderDetailsStream(
      String orderId,
      ) {
    return firestore
        .collection('orders')
        .doc(orderId)
        .snapshots();
  }

  String getDate(dynamic value) {
    if (value == null) {
      return "";
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(
        value.toString(),
      );
    }

    if (date == null) {
      return "";
    }

    String day =
    date.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    String month =
    date.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    String year =
    date.year.toString();

    return "$day/$month/$year";
  }

  bool placed(String status) {
    String value =
    status
        .trim()
        .toLowerCase();

    return value == "pending" ||
        value == "placed" ||
        value == "accept" ||
        value == "accepted" ||
        value == "ready" ||
        value == "completed";
  }

  bool accepted(String status) {
    String value =
    status
        .trim()
        .toLowerCase();

    return value == "accept" ||
        value == "accepted" ||
        value == "ready" ||
        value == "completed";
  }

  bool ready(String status) {
    String value =
    status
        .trim()
        .toLowerCase();

    return value == "ready" ||
        value == "completed";
  }

  bool completed(String status) {
    return status
        .trim()
        .toLowerCase() ==
        "completed";
  }

  double getItemsTotal(
      List<QueryDocumentSnapshot<
          Map<String, dynamic>>>
      docs,
      ) {
    double total = 0.0;

    for (var snap in docs) {
      Map<String, dynamic> data =
      snap.data();

      double price =
      getDouble(
        data['price'],
      );

      double qty =
      getDouble(
        data['qty'],
      );

      total += price * qty;
    }

    return total;
  }

  double getDeliveryCharge(
      List<QueryDocumentSnapshot<
          Map<String, dynamic>>>
      docs,
      ) {
    if (docs.isEmpty) {
      return 0.0;
    }

    return 40.0;
  }

  double getTotalAmount(
      double itemsTotal,
      double deliveryCharge,
      ) {
    return itemsTotal +
        deliveryCharge;
  }

  Future<double> getProductStock(
      String productId,
      ) async {
    try {
      DocumentSnapshot<
          Map<String, dynamic>>
      product =
      await firestore
          .collection(
        'productsdata',
      )
          .doc(productId)
          .get();

      if (!product.exists) {
        return 0.0;
      }

      Map<String, dynamic>? data =
      product.data();

      if (data == null) {
        return 0.0;
      }

      return getDouble(
        data['pquantity'],
      );
    } catch (e) {
      print(e);
      return 0.0;
    }
  }

  Future<void> increaseQty(
      QueryDocumentSnapshot<
          Map<String, dynamic>>
      snap,
      ) async {
    try {
      Map<String, dynamic> data =
      snap.data();

      double currentQty =
      getDouble(
        data['qty'],
      );

      bool kgProduct =
      isKgProduct(
        data['unit'],
      );

      double step =
      kgProduct
          ? 0.1
          : 1.0;

      double newQty =
      normalizeQty(
        currentQty + step,
      );

      String productId =
          data['productId']
              ?.toString() ??
              "";

      if (productId.isEmpty) {
        return;
      }

      double stock =
      await getProductStock(
        productId,
      );

      if (stock <= 0) {
        return;
      }

      if (newQty > stock) {
        return;
      }

      await firestore
          .collection('cart')
          .doc(snap.id)
          .update({
        'qty': newQty,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> decreaseQty(
      QueryDocumentSnapshot<
          Map<String, dynamic>>
      snap,
      ) async {
    try {
      Map<String, dynamic> data =
      snap.data();

      double currentQty =
      getDouble(
        data['qty'],
      );

      bool kgProduct =
      isKgProduct(
        data['unit'],
      );

      double step =
      kgProduct
          ? 0.1
          : 1.0;

      double minimumQty =
      kgProduct
          ? 0.1
          : 1.0;

      double newQty =
      normalizeQty(
        currentQty - step,
      );

      if (newQty <
          minimumQty) {
        return;
      }

      await firestore
          .collection('cart')
          .doc(snap.id)
          .update({
        'qty': newQty,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteItem(
      String id,
      ) async {
    try {
      await firestore
          .collection('cart')
          .doc(id)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> clearCart(
      String uid,
      ) async {
    try {
      QuerySnapshot<
          Map<String, dynamic>>
      snapshot =
      await firestore
          .collection('cart')
          .where(
        'uid',
        isEqualTo: uid,
      )
          .get();

      WriteBatch batch =
      firestore.batch();

      for (var doc
      in snapshot.docs) {
        batch.delete(
          doc.reference,
        );
      }

      await batch.commit();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getAddress() async {
    User? currentUser =
    _addressRepository
        .getCurrentUser();

    if (currentUser == null) {
      address =
      "No address selected";

      notifyListeners();
      return;
    }

    try {
      QuerySnapshot<
          Map<String, dynamic>>
      snapshot =
      await _addressRepository
          .getUserAddresses(
        currentUser.uid,
      );

      print(
        "ADDRESS COUNT: ${snapshot.docs.length}",
      );

      if (snapshot.docs.isEmpty) {
        address =
        "No address selected";

        notifyListeners();
        return;
      }

      QueryDocumentSnapshot<
          Map<String, dynamic>>?
      defaultAddress;

      for (var doc
      in snapshot.docs) {
        Map<String, dynamic> data =
        doc.data();

        print(
          "ADDRESS DATA: $data",
        );

        bool isDefault =
            data['isDefault'] ==
                true;

        if (isDefault) {
          defaultAddress =
              doc;
          break;
        }
      }

      if (defaultAddress ==
          null) {
        address =
        "No address selected";

        notifyListeners();
        return;
      }

      Map<String, dynamic> data =
      defaultAddress.data();

      String street =
          data['address']
              ?.toString()
              .trim() ??
              "";

      String city =
          data['city']
              ?.toString()
              .trim() ??
              "";

      if (street.isNotEmpty &&
          city.isNotEmpty) {
        address =
        "$street, $city";
      } else if (street.isNotEmpty) {
        address =
            street;
      } else if (city.isNotEmpty) {
        address =
            city;
      } else {
        address =
        "No address selected";
      }

      print(
        "SELECTED ADDRESS: $address",
      );

      notifyListeners();
    } catch (e) {
      print(
        "GET ADDRESS ERROR: $e",
      );

      address =
      "No address selected";

      notifyListeners();
    }
  }

  bool hasAddress() {
    String value =
    address.trim();

    return value.isNotEmpty &&
        value.toLowerCase() !=
            "no address selected";
  }

  Future<bool> checkStock(
      BuildContext context,
      List<QueryDocumentSnapshot<
          Map<String, dynamic>>>
      docs,
      ) async {
    for (var snap in docs) {
      Map<String, dynamic> data =
      snap.data();

      String productId =
          data['productId']
              ?.toString() ??
              "";

      String productName =
          data['pname']
              ?.toString() ??
              "Product";

      double orderQty =
      getDouble(
        data['qty'],
      );

      bool kgProduct =
      isKgProduct(
        data['unit'],
      );

      if (productId.isEmpty) {
        continue;
      }

      double stock =
      await getProductStock(
        productId,
      );

      if (stock <= 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                "$productName is currently unavailable",
              ),
              backgroundColor:
              Colors.red,
            ),
          );
        }

        return false;
      }

      if (orderQty > stock) {
        if (context.mounted) {
          String available;

          if (kgProduct) {
            available =
            "${displayQty(stock)} KG";
          } else {
            available =
                displayQty(stock);
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                "Only $available of $productName available",
              ),
              backgroundColor:
              Colors.red,
            ),
          );
        }

        return false;
      }
    }

    return true;
  }

  Future<void> placeOrder(
      BuildContext context,
      List<QueryDocumentSnapshot<
          Map<String, dynamic>>>
      docs,
      double itemsTotal,
      double deliveryCharge,
      double totalAmount,
      String uid,
      ) async {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Cart is empty",
          ),
          backgroundColor:
          Colors.red,
        ),
      );

      return;
    }

    await getAddress();

    if (!hasAddress()) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              "Please select a default delivery address",
            ),
            backgroundColor:
            Colors.red,
          ),
        );
      }

      return;
    }

    if (isLoading) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      bool available =
      await checkStock(
        context,
        docs,
      );

      if (!available) {
        return;
      }

      List<Map<String, dynamic>>
      items = [];

      for (var snap
      in docs) {
        Map<String, dynamic> data =
        snap.data();

        double price =
        getDouble(
          data['price'],
        );

        double qty =
        getDouble(
          data['qty'],
        );

        items.add({
          'productId':
          data['productId']
              ?.toString() ??
              "",
          'pname':
          data['pname']
              ?.toString() ??
              "",
          'price':
          price,
          'qty':
          qty,
          'unit':
          data['unit']
              ?.toString() ??
              "",
          'pcatogory':
          data['pcatogory']
              ?.toString() ??
              "",
        });
      }

      DocumentReference<
          Map<String, dynamic>>
      orderDoc =
      firestore
          .collection(
        'orders',
      )
          .doc();

      String id =
          orderDoc.id;

      String orderNo;

      if (id.length >= 6) {
        orderNo =
        "OD-${id.substring(0, 6).toUpperCase()}";
      } else {
        orderNo =
        "OD-${id.toUpperCase()}";
      }

      await orderDoc.set({
        'orderId':
        orderDoc.id,
        'orderNo':
        orderNo,
        'uid':
        uid,
        'userId':
        uid,
        'items':
        items,
        'itemsTotal':
        itemsTotal,
        'deliveryCharge':
        deliveryCharge,
        'totalAmount':
        totalAmount,
        'address':
        address,
        'paymentMethod':
        paymentMethod,
        'status':
        'Pending',
        'stockDeducted':
        false,
        'date':
        FieldValue
            .serverTimestamp(),
        'createdAt':
        FieldValue
            .serverTimestamp(),
      });

      WriteBatch batch =
      firestore.batch();

      for (var snap
      in docs) {
        batch.delete(
          snap.reference,
        );
      }

      await batch.commit();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Order placed successfully",
          ),
          backgroundColor:
          Colors.green,
        ),
      );
    } catch (e) {
      print(
        "PLACE ORDER ERROR: $e",
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to place order",
            ),
            backgroundColor:
            Colors.red,
          ),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}