import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/models/seller_items.dart';
import 'dart:convert';
import 'items_details_screen.dart'; // Replace with your item details screen
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart'; // Add the necessary import

class SellerProductsScreen extends StatefulWidget {
  final String sellerID;
  final String userID;
  final String sellerProfile;
  final String sellerRating;
  final String sellerName;

  SellerProductsScreen(
      {required this.sellerID,
      required this.userID,
      required this.sellerRating,
      required this.sellerProfile,
      required this.sellerName});

  @override
  _SellerProductsScreenState createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  @override
  void initState() {
    super.initState();
    // fetchSellerInfo(widget.model!.sellerUID.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller's Products"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    API.sellerImage + widget.sellerProfile,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sellerName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SmoothStarRating(
                      rating: double.tryParse(widget.sellerRating) ??
                          0.0, // Convert String to double
                      starCount: 5,
                      color: Colors.pinkAccent,
                      borderColor: Colors.pinkAccent,
                      size: 12,
                    ),

                    // SmoothStarRating(
                    //   rating: widget.sellerRating,
                    //   starCount: 5,
                    //   color: Colors.pinkAccent,
                    //   borderColor: Colors.pinkAccent,
                    //   size: 12,
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Items>>(
              stream: getItemStream(widget.userID, widget.sellerID),
              builder: (context, AsyncSnapshot<List<Items>> dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (dataSnapshot.hasData &&
                    dataSnapshot.data!.isNotEmpty) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: dataSnapshot.data!.length,
                    itemBuilder: (context, index) {
                      Items model = dataSnapshot.data![index];
                      String? thumbnailUrl = model.thumbnailUrl;

                      return InkWell(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (c) => ItemsDetailsScreen(model: model),
                        //     ),
                        //   );
                        // },
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 233, 230, 230),
                                    spreadRadius: 0.1,
                                    blurRadius: 5,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 170,
                                    height: 160,
                                    padding: EdgeInsets.all(8),
                                    child: thumbnailUrl != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  API.getItemsImage +
                                                      thumbnailUrl,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    model.itemTitle.toString(),
                                    style: TextStyle(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    model.itemInfo.toString(),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "₹ ${model.price.toString()}",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.green),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text("No Items Data exists for this seller."),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<Items>> getItemStream(String userId, String sellerId) async* {
    final response = await http.post(
      Uri.parse(API.displayItemss),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
        'seller_id': sellerId, // Send seller ID to filter items
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      yield data.map((itemData) => Items.fromJson(itemData)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }
}
