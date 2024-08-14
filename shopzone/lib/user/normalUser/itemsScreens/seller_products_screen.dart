import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/models/seller_items.dart';
import 'dart:convert';
import 'items_details_screen.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class SellerProductsScreen extends StatefulWidget {
  final String sellerID;
  final String userID;
  final String sellerProfile;
  final String sellerRating;
  final String sellerName;

  SellerProductsScreen(
      {required this.sellerID,
      required this.userID,
      required this.sellerProfile,
      required this.sellerRating,
      required this.sellerName});

  @override
  _SellerProductsScreenState createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  String sellerName = "";
  String sellerProfile = "";
  double sellerRating = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchSellerInfo(String? sellerID) async {
    if (sellerID == null) return;

    final url = Uri.parse("${API.fetchSellerInfo}?sellerID=$sellerID");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);

      if (jsonResponse['success']) {
        setState(() {
          sellerName = jsonResponse['data']['seller_name'];
          sellerProfile = jsonResponse['data']['seller_profile'];
          sellerRating = jsonResponse['data']['rating'].toDouble();
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Failed to load seller information.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller's Products"),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              // Background image
              Container(
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/b.png'), // Ensure the path matches the one in pubspec.yaml
                    fit: BoxFit.cover,
                  ),
                 
                ),
              ),
              // Overlay with gradient
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                
                ),
              ),
              // Overlay with seller's profile and information
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(
                            API.sellerImage + widget.sellerProfile,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        widget.sellerName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 5),
                      SmoothStarRating(
                        rating: double.tryParse(widget.sellerRating) ?? 0.0,
                        starCount: 5,
                        color: Colors.amber,
                        borderColor: Colors.white,
                        size: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (c) => ItemsDetailsScreen(model:model),
                          //   ),
                          // );
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
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
        'seller_id': sellerId,
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
