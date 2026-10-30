import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/order_viewmodel.dart';
import '../profile/adress.dart';

class Order extends StatefulWidget {
  Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<OrderViewmodel>(
        context,
        listen: false,
      ).loadOrderData();
    });
  }

  void changePayment(OrderViewmodel provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Payment Method"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Cash on Delivery"),
                onTap: () {
                  provider.changePayment("Cash on Delivery");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("UPI"),
                onTap: () {
                  provider.changePayment("UPI");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Card"),
                onTap: () {
                  provider.changePayment("Card");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderViewmodel>(
      context,
    );

    var user = provider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text("Please login first"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              await provider.clearCart(user.uid);
            },
            child: Text(
              "Clear cart",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: provider.cartStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text("Cart is empty"),
            );
          }

          var docs = snapshot.data!.docs;

          double itemsTotal = provider.getItemsTotal(docs);
          double deliveryCharge = provider.getDeliveryCharge(docs);
          double totalAmount = provider.getTotalAmount(
            itemsTotal,
            deliveryCharge,
          );

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cart Items",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (docs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text("Your cart is empty"),
                        ],
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var snap = docs[index];
                      var data = snap.data();

                      String name = data['pname']?.toString() ?? "";
                      String unit = data['unit']?.toString() ?? "";
                      double price = double.tryParse(data['price']?.toString() ?? "0") ?? 0;
                      int qty = int.tryParse(data['qty']?.toString() ?? "1") ?? 1;
                      double itemTotal = price * qty;

                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(unit),
                                    SizedBox(height: 4),
                                    Text(
                                      "₹${price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Total: ₹${itemTotal.toStringAsFixed(2)}",
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await provider.decreaseQty(snap);
                                          },
                                          icon: Icon(Icons.remove),
                                        ),
                                        Text(
                                          qty.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await provider.increaseQty(snap);
                                          },
                                          icon: Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await provider.deleteItem(snap.id);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Items Total"),
                              Text("₹${itemsTotal.toStringAsFixed(2)}"),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery Charge"),
                              Text("₹${deliveryCharge.toStringAsFixed(2)}"),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Amount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "₹${totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Delivery Address",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      title: Text("HOME"),
                      subtitle: Text(provider.address),
                      trailing: TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Manageaddress(),
                            ),
                          );
                          await provider.getAddress();
                        },
                        child: Text("Change"),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.payment,
                        color: Colors.blue,
                      ),
                      title: Text(provider.paymentMethod),
                      trailing: TextButton(
                        onPressed: () {
                          changePayment(provider);
                        },
                        child: Text("Change"),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (docs.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Cart is empty"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await provider.placeOrder(
                          context,
                          docs,
                          itemsTotal,
                          deliveryCharge,
                          totalAmount,
                          user.uid,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "PLACE ORDER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}