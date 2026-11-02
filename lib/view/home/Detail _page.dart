import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/detail_viewmodel.dart';

class Detail extends StatefulWidget {
  final dynamic snap;

  const Detail({
    super.key,
    required this.snap,
  });

  @override
  State<Detail> createState() =>
      _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DetailViewmodel(
            snap: widget.snap,
          ),
      child: Consumer<DetailViewmodel>(
        builder:
            (context, provider, child) {
          final isAvailable =
              provider.isAvailable;

          String image =
              provider.snap['pimage']
                  ?.toString() ??
                  "";

          return Scaffold(
            backgroundColor:
            Colors.grey.shade100,
            appBar: AppBar(
              title: Text(
                "Product Details",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              backgroundColor:
              Colors.blue,
              foregroundColor:
              Colors.white,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding:
              EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Container(
                    height: 240,
                    width:
                    double.infinity,
                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                          16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                              0.04),
                          blurRadius: 6,
                          offset:
                          Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius
                          .circular(
                          16),
                      child:
                      image.isEmpty
                          ? Center(
                        child:
                        Icon(
                          Icons
                              .inventory_2_outlined,
                          size:
                          80,
                          color: Colors
                              .grey
                              .shade400,
                        ),
                      )
                          : Image
                          .network(
                        image,
                        fit: BoxFit
                            .cover,
                        errorBuilder:
                            (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return Center(
                            child:
                            Icon(
                              Icons
                                  .inventory_2_outlined,
                              size:
                              80,
                              color: Colors
                                  .grey
                                  .shade400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Card(
                    elevation: 1.5,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                          16),
                    ),
                    child: Padding(
                      padding:
                      EdgeInsets.all(
                          16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  provider.snap[
                                  'pname']
                                      ?.toString() ??
                                      "",
                                  style:
                                  TextStyle(
                                    fontSize:
                                    22,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),
                              ),

                              SizedBox(
                                  width: 10),

                              Text(
                                "₹${provider.snap['pselling price']?.toString() ?? '0'}",
                                style:
                                TextStyle(
                                  fontSize:
                                  22,
                                  color: Colors
                                      .blue
                                      .shade900,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                              height: 12),

                          Container(
                            padding:
                            EdgeInsets
                                .symmetric(
                              horizontal:
                              10,
                              vertical: 5,
                            ),
                            decoration:
                            BoxDecoration(
                              color: isAvailable
                                  ? Colors
                                  .green
                                  .shade50
                                  : Colors
                                  .red
                                  .shade50,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  8),
                              border:
                              Border.all(
                                color: isAvailable
                                    ? Colors
                                    .green
                                    .shade300
                                    : Colors
                                    .red
                                    .shade300,
                              ),
                            ),
                            child: Text(
                              isAvailable
                                  ? "In Stock"
                                  : "Currently Unavailable",
                              style:
                              TextStyle(
                                fontSize: 12,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color: isAvailable
                                    ? Colors
                                    .green
                                    .shade800
                                    : Colors
                                    .red
                                    .shade800,
                              ),
                            ),
                          ),

                          Divider(
                              height: 24),

                          _buildDetailRow(
                            icon: Icons
                                .category_outlined,
                            label:
                            "Category",
                            value: provider
                                .snap[
                            'pcatogory']
                                ?.toString() ??
                                "N/A",
                          ),

                          SizedBox(
                              height: 10),

                          _buildDetailRow(
                            icon: Icons
                                .straighten_outlined,
                            label: "Unit",
                            value: provider
                                .snap[
                            'punits']
                                ?.toString() ??
                                "N/A",
                          ),

                          SizedBox(
                              height: 10),

                          _buildDetailRow(
                            icon: Icons
                                .inventory_outlined,
                            label:
                            "Available Stock",

                            // KG shows:
                            // 0.1 KG, 0.5 KG, 2.5 KG
                            //
                            // Other units show:
                            // 1, 2, 3 etc.
                            value: provider
                                .isKgProduct
                                ? "${provider.displayStock} KG"
                                : provider
                                .displayStock,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  if (!isAvailable)
                    Container(
                      width:
                      double.infinity,
                      padding:
                      EdgeInsets.all(
                          14),
                      decoration:
                      BoxDecoration(
                        color: Colors
                            .red.shade50,
                        borderRadius:
                        BorderRadius
                            .circular(
                            12),
                        border:
                        Border.all(
                          color: Colors
                              .red
                              .shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .info_outline,
                            color:
                            Colors.red,
                          ),
                          SizedBox(
                              width: 10),
                          Expanded(
                            child: Text(
                              "This product is currently unavailable",
                              style:
                              TextStyle(
                                color: Colors
                                    .red
                                    .shade800,
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isAvailable)
                    Card(
                      elevation: 1.5,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                            16),
                      ),
                      child: Padding(
                        padding:
                        EdgeInsets
                            .symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              provider
                                  .isKgProduct
                                  ? "Quantity (KG)"
                                  : "Quantity",
                              style:
                              TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            Spacer(),

                            Container(
                              decoration:
                              BoxDecoration(
                                color: Colors
                                    .grey
                                    .shade100,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                    12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () {
                                      provider
                                          .decrementQty();
                                    },
                                    icon:
                                    Icon(
                                      Icons
                                          .remove,
                                      color:
                                      Colors
                                          .blue,
                                    ),
                                  ),

                                  // KG:
                                  // 0.1, 0.2, 0.3...
                                  //
                                  // Normal:
                                  // 1, 2, 3...
                                  Text(
                                    provider
                                        .displayQty,
                                    style:
                                    TextStyle(
                                      fontSize:
                                      16,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  IconButton(
                                    onPressed:
                                        () {
                                      provider
                                          .incrementQty();
                                    },
                                    icon:
                                    Icon(
                                      Icons.add,
                                      color:
                                      Colors
                                          .blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 24),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 50,
                    child:
                    ElevatedButton(
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.blue,
                        foregroundColor:
                        Colors.white,
                        disabledBackgroundColor:
                        Colors
                            .grey
                            .shade400,
                        disabledForegroundColor:
                        Colors.white,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                              12),
                        ),
                      ),
                      onPressed:
                      (!isAvailable ||
                          provider
                              .isAdding)
                          ? null
                          : () async {
                        await provider
                            .addToCart(
                          context,
                        );
                      },
                      child: provider
                          .isAdding
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,
                          color: Colors
                              .white,
                        ),
                      )
                          : Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          Icon(
                            isAvailable
                                ? Icons
                                .shopping_cart_outlined
                                : Icons
                                .block,
                            size: 20,
                          ),
                          SizedBox(
                              width: 8),
                          Text(
                            isAvailable
                                ? "Add to Cart"
                                : "Currently Unavailable",
                            style:
                            TextStyle(
                              fontSize:
                              16,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
          Colors.grey.shade600,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color:
            Colors.grey.shade600,
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ],
    );
  }
}