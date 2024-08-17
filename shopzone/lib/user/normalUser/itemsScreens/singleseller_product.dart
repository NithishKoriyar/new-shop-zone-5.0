import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'items_details_screen.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/models/seller_items.dart';

class SellerItemsScreen extends StatefulWidget {
  final String sellerID;
  final String userID;

  SellerItemsScreen({required this.sellerID, required this.userID});

  @override
  _SellerItemsScreenState createState() => _SellerItemsScreenState();
}

class _SellerItemsScreenState extends State<SellerItemsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller's Products"),
      ),
      body: Expanded(
        child: StreamBuilder<List<Items>>(
          stream: getItemStream(widget.userID, widget.sellerID),
          builder: (context, AsyncSnapshot<List<Items>> dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
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
