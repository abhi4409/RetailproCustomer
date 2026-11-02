import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/order_viewmodel.dart';

class OrderStatus extends StatefulWidget {
  final String orderId;

  const OrderStatus({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderStatus> createState() =>
      _OrderStatusState();
}

class _OrderStatusState
    extends State<OrderStatus> {
  String statusText(
      String status,
      ) {
    switch (status
        .trim()
        .toLowerCase()) {
      case "pending":
      case "placed":
      case "order placed":
        return "Order Placed";

      case "accept":
      case "accepted":
        return "Accepted";

      case "ready":
        return "Ready";

      case "completed":
        return "Completed";

      case "rejected":
        return "Rejected";

      default:
        return status;
    }
  }

  Color statusColor(
      String status,
      ) {
    switch (status
        .trim()
        .toLowerCase()) {
      case "pending":
      case "placed":
      case "order placed":
        return Colors.blue;

      case "accept":
      case "accepted":
        return Colors.orange;

      case "ready":
        return Colors.purple;

      case "completed":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Widget trackingItem({
    required String title,
    required String subtitle,
    required bool completed,
    bool rejected = false,
  }) {
    Color color = rejected
        ? Colors.red
        : completed
        ? Colors.green
        : Colors.grey;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(
                  0.12,
                ),
              ),
              child: Icon(
                rejected
                    ? Icons.close
                    : completed
                    ? Icons.check
                    : Icons.circle_outlined,
                color: color,
                size: 20,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 14,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 2,
              bottom: 22,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color: rejected
                        ? Colors.red
                        : completed
                        ? Colors.black87
                        : Colors
                        .grey.shade600,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    var provider =
    Provider.of<OrderViewmodel>(
      context,
    );

    return Scaffold(
      backgroundColor:
      Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Order Tracking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream:
        provider.orderDetailsStream(
          widget.orderId,
        ),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Unable to track order",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Text(
                "Order not found",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            );
          }

          var data =
          snapshot.data!.data();

          if (data == null) {
            return Center(
              child: Text(
                "Order not found",
              ),
            );
          }

          String orderNo =
              data['orderNo']
                  ?.toString() ??
                  "";

          String status =
              data['status']
                  ?.toString() ??
                  "Pending";

          String address =
              data['address']
                  ?.toString() ??
                  "";

          String paymentMethod =
              data['paymentMethod']
                  ?.toString() ??
                  "";

          double totalAmount =
              double.tryParse(
                data['totalAmount']
                    ?.toString() ??
                    "0",
              ) ??
                  0.0;

          double itemsTotal =
              double.tryParse(
                data['itemsTotal']
                    ?.toString() ??
                    "0",
              ) ??
                  0.0;

          double deliveryCharge =
              double.tryParse(
                data['deliveryCharge']
                    ?.toString() ??
                    "0",
              ) ??
                  0.0;

          List items =
          data['items'] is List
              ? data['items']
              : [];

          String date =
          provider.getDate(
            data['createdAt'] ??
                data['date'],
          );

          bool placed =
          provider.placed(
            status,
          );

          bool accepted =
          provider.accepted(
            status,
          );

          bool ready =
          provider.ready(
            status,
          );

          bool completed =
          provider.completed(
            status,
          );

          bool rejected =
              status
                  .trim()
                  .toLowerCase() ==
                  "rejected";

          return SingleChildScrollView(
            padding:
            EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.all(18),
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.04,
                        ),
                        blurRadius: 6,
                        offset:
                        Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              orderNo,
                              style:
                              TextStyle(
                                fontSize:
                                20,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color: Colors
                                    .blue
                                    .shade900,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                            EdgeInsets
                                .symmetric(
                              horizontal:
                              12,
                              vertical:
                              6,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              statusColor(
                                status,
                              ).withOpacity(
                                0.12,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              statusText(
                                status,
                              ),
                              style:
                              TextStyle(
                                fontSize:
                                12,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color:
                                statusColor(
                                  status,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (date
                          .isNotEmpty) ...[
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .calendar_today_outlined,
                              size: 15,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              date,
                              style:
                              TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,
                                fontSize:
                                13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.all(18),
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.04,
                        ),
                        blurRadius: 6,
                        offset:
                        Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        "Order Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      trackingItem(
                        title:
                        "Order Placed",
                        subtitle:
                        "Your order has been placed successfully",
                        completed:
                        placed ||
                            rejected,
                      ),

                      if (rejected)
                        trackingItem(
                          title:
                          "Order Rejected",
                          subtitle:
                          "Your order was rejected by the shop",
                          completed:
                          false,
                          rejected:
                          true,
                        )
                      else ...[
                        trackingItem(
                          title:
                          "Order Accepted",
                          subtitle: accepted
                              ? "Shop accepted your order"
                              : "Waiting for shop acceptance",
                          completed:
                          accepted,
                        ),
                        trackingItem(
                          title: "Ready",
                          subtitle: ready
                              ? "Your order is ready"
                              : "Waiting for your order to be ready",
                          completed:
                          ready,
                        ),
                        trackingItem(
                          title:
                          "Completed",
                          subtitle: completed
                              ? "Order completed successfully"
                              : "Waiting for order completion",
                          completed:
                          completed,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.all(18),
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.04,
                        ),
                        blurRadius: 6,
                        offset:
                        Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        "Order Items",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 12,
                      ),

                      if (items.isEmpty)
                        Text(
                          "No items found",
                          style: TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics:
                          NeverScrollableScrollPhysics(),
                          itemCount:
                          items.length,
                          separatorBuilder:
                              (
                              context,
                              index,
                              ) {
                            return Divider();
                          },
                          itemBuilder: (
                              context,
                              index,
                              ) {
                            var item =
                            items[index];

                            String name =
                                item['pname']
                                    ?.toString() ??
                                    "Product";

                            double price =
                                double.tryParse(
                                  item['price']
                                      ?.toString() ??
                                      "0",
                                ) ??
                                    0.0;

                            double qty =
                                double.tryParse(
                                  item['qty']
                                      ?.toString() ??
                                      "0",
                                ) ??
                                    0.0;

                            String unit =
                                item['unit']
                                    ?.toString() ??
                                    "";

                            bool kg =
                            provider
                                .isKgProduct(
                              unit,
                            );

                            String qtyText =
                            provider
                                .displayQty(
                              qty,
                            );

                            double total =
                                price * qty;

                            return Padding(
                              padding:
                              EdgeInsets
                                  .symmetric(
                                vertical: 5,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height:
                                    42,
                                    width:
                                    42,
                                    decoration:
                                    BoxDecoration(
                                      color: Colors
                                          .blue
                                          .shade50,
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        10,
                                      ),
                                    ),
                                    child:
                                    Icon(
                                      Icons
                                          .shopping_bag_outlined,
                                      color:
                                      Colors.blue,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                    12,
                                  ),
                                  Expanded(
                                    child:
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          name,
                                          style:
                                          TextStyle(
                                            fontSize:
                                            14,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                          4,
                                        ),
                                        Text(
                                          kg
                                              ? "$qtyText KG × ₹${price.toStringAsFixed(2)}"
                                              : "$qtyText × ₹${price.toStringAsFixed(2)}",
                                          style:
                                          TextStyle(
                                            fontSize:
                                            12,
                                            color: Colors
                                                .grey
                                                .shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${total.toStringAsFixed(2)}",
                                    style:
                                    TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  EdgeInsets.all(18),
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.04,
                        ),
                        blurRadius: 6,
                        offset:
                        Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        "Delivery Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 15,
                      ),

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            color:
                            Colors.red,
                            size: 22,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              address
                                  .isNotEmpty
                                  ? address
                                  : "No address provided",
                              style:
                              TextStyle(
                                fontSize:
                                14,
                                color: Colors
                                    .grey
                                    .shade700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Text(
                        "Payment Method",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 12,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons
                                .payment_outlined,
                            color:
                            Colors.blue,
                            size: 22,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            paymentMethod
                                .isNotEmpty
                                ? paymentMethod
                                : "N/A",
                            style:
                            TextStyle(
                              fontSize:
                              14,
                              color: Colors
                                  .grey
                                  .shade700,
                            ),
                          ),
                        ],
                      ),

                      Divider(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Text(
                            "Items Total",
                          ),
                          Text(
                            "₹${itemsTotal.toStringAsFixed(2)}",
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Text(
                            "Delivery Charge",
                          ),
                          Text(
                            "₹${deliveryCharge.toStringAsFixed(2)}",
                          ),
                        ],
                      ),

                      Divider(
                        height: 25,
                      ),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style:
                            TextStyle(
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                          Text(
                            "₹${totalAmount.toStringAsFixed(2)}",
                            style:
                            TextStyle(
                              fontSize:
                              18,
                              fontWeight:
                              FontWeight
                                  .bold,
                              color: Colors
                                  .blue
                                  .shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}