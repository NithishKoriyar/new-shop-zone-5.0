import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/foodUser/foodUserItemsScreens/items_details_screen.dart';
import 'package:shopzone/user/models/items.dart';

import 'package:http/http.dart' as http;

class WishListScreen extends StatefulWidget {
  final String userID;
  WishListScreen({required this.userID});
  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late List<Items> wishListItems = [];

  @override
  void initState() {
    super.initState();
    fetchWishListItems(
        widget.userID); // Use widget.userID to access the userID property
  }

  Future<void> fetchWishListItems(String userID) async {
    try {
      final response = await http.get(
        Uri.parse('${API.fetchWishListItems}?userID=$userID'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          wishListItems = data.map((item) => Items.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load wishListItems');
      }
    } catch (e) {
      print('Error fetching wishListItems: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wish List Items"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: wishListItems.length,
                itemBuilder: (context, index) {
                  final item =
                      wishListItems[index]; // Correctly reference the item
                  return Padding(
                    padding:
                        const EdgeInsets.all(0), // Adjust padding as needed
                    child: InkWell(
                      onTap: () {
                        // Navigate to the ItemsDetailsScreen and pass the selected item model
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemsDetailsScreen(model: item),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.amberAccent,
                        elevation: 4.0, // Adjust elevation as needed
                        child: Stack(
                          // Add a Stack widget to correctly position the IconButton
                          children: [
                            GridTile(
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        8.0,
                                      ), // Adjust padding as needed
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            8.0), // Set the border radius as needed
                                        child: Image.network(
                                          API.getItemsImage +
                                              (item.thumbnailUrl ??
                                                  ''), // Correctly handle possible null
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.itemTitle ?? 'Unnamed Item',
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    "₹ ${item.price}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 21, 0, 255)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      item.itemInfo ?? 'Unnamed Item',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 82, 82, 82),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  print(item.isWishListed);
                                  toggleWishlist(item, widget.userID);
                                },
                                child: Container(
                                  child: Icon(
                                    item.isWishListed == "1"
                                        ? Icons.remove_circle_outlined
                                        : Icons.remove_circle_outlined,
                                    color: item.isWishListed == "1"
                                        ? Colors.orange
                                        : Colors.orange,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void toggleWishlist(Items model, userId) {
    setState(() {
      model.isWishListed = (model.isWishListed == "1" ? "0" : "1").toString();
    });

    // You can update this in your backend or local database here
    updateWishlistInBackend(model, userId);
  }

void updateWishlistInBackend(Items model, userId) async {
  const String apiUrl = API.wishListToggle;
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'item_id': model.itemID,
    }),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    if (result['status'] == 'error') {
      print('Error updating wishlist: ${result['message']}');
    } else {
      print('Wishlist status: ${result['status']}');
      // Refresh the wishlist after updating
      fetchWishListItems(userId);
    }
  } else {
    print('Server error: ${response.statusCode}');
  }
}

}
