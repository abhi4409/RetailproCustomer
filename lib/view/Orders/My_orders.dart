import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/order_viewmodel.dart';
import 'Order.dart';

class Myordes extends StatefulWidget {
  const Myordes({
    super.key,
  });

  @override
  State<Myordes> createState() => _MyordesState();
}

class _MyordesState extends State<Myordes> {
  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case "pending":
      case "placed":
      case "order placed":
        return Colors.blue;

      case "accepted":
      case "accept":
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

  String _getStatusText(String status) {
    switch (status.trim().toLowerCase()) {
      case "pending":
      case "placed":
      case "order placed":
        return "Order Placed";

      case "accepted":
      case "accept":
        return "Accepted";

      case "ready":
        return "Ready";

      case "completed":
        return "Completed";

      case "rejected":
        return "Rejected";

      default:
        return status.isEmpty
            ? "Order Placed"
            : status;
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<OrderViewmodel>(
      context,
    );

    var user = provider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(
            "My Orders",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            "Please login to view your orders",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Orders",
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
          QuerySnapshot<Map<String, dynamic>>>(
        stream: provider.orderStream(
          user.uid,
        ),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Unable to load orders",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      snapshot.error.toString(),
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .shopping_bag_outlined,
                    size: 70,
                    color:
                    Colors.grey.shade400,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "No orders found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Your orders will appear here",
                    style: TextStyle(
                      fontSize: 13,
                      color:
                      Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders =
          snapshot.data!.docs.toList();

          orders.sort(
                (a, b) {
              dynamic aDate =
                  a.data()['createdAt'] ??
                      a.data()['date'];

              dynamic bDate =
                  b.data()['createdAt'] ??
                      b.data()['date'];

              if (aDate is Timestamp &&
                  bDate is Timestamp) {
                return bDate.compareTo(
                  aDate,
                );
              }

              return 0;
            },
          );

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            itemCount: orders.length,
            separatorBuilder: (
                context,
                index,
                ) {
              return SizedBox(
                height: 12,
              );
            },
            itemBuilder: (
                context,
                index,
                ) {
              final snap =
              orders[index];

              final data =
              snap.data();

              final String orderNo =
                  data['orderNo']
                      ?.toString() ??
                      "OD-N/A";

              final String status =
                  data['status']
                      ?.toString() ??
                      "Pending";

              final String statusText =
              _getStatusText(
                status,
              );

              final double totalAmount =
                  double.tryParse(
                    data['totalAmount']
                        ?.toString() ??
                        "0",
                  ) ??
                      0.0;

              final List items =
              data['items'] is List
                  ? data['items']
                  : [];

              final String date =
              provider.getDate(
                data['createdAt'] ??
                    data['date'],
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                          OrderStatus(
                            orderId:
                            snap.id,
                          ),
                    ),
                  );
                },
                child: Container(
                  padding:
                  EdgeInsets.all(16),
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
                                16,
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
                              10,
                              vertical:
                              5,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              _getStatusColor(
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
                              statusText,
                              style:
                              TextStyle(
                                fontSize:
                                12,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color:
                                _getStatusColor(
                                  status,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons
                                .shopping_cart_outlined,
                            size: 17,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            "${items.length} ${items.length == 1 ? 'item' : 'items'}",
                            style:
                            TextStyle(
                              fontSize:
                              13,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                      if (date
                          .isNotEmpty) ...[
                        SizedBox(
                          height: 7,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .calendar_today_outlined,
                              size: 16,
                              color: Colors
                                  .grey
                                  .shade500,
                            ),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              date,
                              style:
                              TextStyle(
                                fontSize:
                                12,
                                color: Colors
                                    .grey
                                    .shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Divider(
                        height: 24,
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
                              14,
                              fontWeight:
                              FontWeight
                                  .w600,
                              color: Colors
                                  .grey
                                  .shade800,
                            ),
                          ),
                          Text(
                            "₹${totalAmount.toStringAsFixed(2)}",
                            style:
                            TextStyle(
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .bold,
                              color: Colors
                                  .black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.end,
                        children: [
                          Text(
                            "Track Order",
                            style:
                            TextStyle(
                              color:
                              Colors.blue,
                              fontWeight:
                              FontWeight
                                  .w600,
                              fontSize:
                              13,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 13,
                            color:
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}