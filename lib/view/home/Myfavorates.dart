import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/favorite_viewmodel.dart';
class Fevorates extends StatefulWidget {
  Fevorates({
    super.key,
  });

  @override
  State<Fevorates> createState() => _FevoratesState();
}

class _FevoratesState extends State<Fevorates> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<FavoriteViewmodel>(
      context,
    );

    var user = provider.user;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? Center(
        child: Text(
          "Please login first",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: provider.favoriteStream(
          user.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade400,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "No favorites added yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;
          var filteredFavorites = provider.filterFavorites(docs);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      provider.searchFavorite(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                      hintText: "Search favorites...",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                Expanded(
                  child: filteredFavorites.isEmpty
                      ? Center(
                    child: Text(
                      "No matching favorites found",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                      : GridView.builder(
                    itemCount: filteredFavorites.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      var snap = filteredFavorites[index];
                      var data = snap.data();

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  FutureBuilder<String>(
                                    future:
                                    provider.getProductImage(
                                      data,
                                    ),
                                    builder:
                                        (context, imageSnapshot) {
                                      String image =
                                          imageSnapshot.data ?? "";

                                      if (imageSnapshot
                                          .connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          color: Colors.grey.shade50,
                                          child: Center(
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Container(
                                        color: Colors.grey.shade50,
                                        child: image.isEmpty
                                            ? Center(
                                          child: Icon(
                                            Icons
                                                .inventory_2_outlined,
                                            size: 40,
                                            color: Colors
                                                .grey.shade400,
                                          ),
                                        )
                                            : Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                              ) {
                                            return Center(
                                              child: Icon(
                                                Icons
                                                    .inventory_2_outlined,
                                                size: 40,
                                                color: Colors
                                                    .grey
                                                    .shade400,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white
                                          .withOpacity(0.9),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize: 18,
                                        onPressed: () async {
                                          await provider
                                              .removeFavorite(
                                            snap.id,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['pname']?.toString() ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    data['pcatogory']?.toString() ??
                                        "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "₹${data['price']?.toString() ?? '0'}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await provider.addToCart(
                                          snap,
                                          context,
                                        );
                                      },
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        Colors.blue,
                                        foregroundColor:
                                        Colors.white,
                                        padding: EdgeInsets.zero,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons
                                            .add_shopping_cart_outlined,
                                        size: 15,
                                      ),
                                      label: Text(
                                        "Add to Cart",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}