import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';
import 'package:shopzone/user/normalUser/sellersScreens/ShopScreen.dart';

class WishListScreen extends StatefulWidget {
  final String userID;
  WishListScreen({required this.userID});
  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late List<Items> wishListItems = [];
  final _wishlistStreamController = StreamController<List<Items>>.broadcast();
  String? selectedSize;
  String? selectedColor;

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
        // Emit a new event to the stream
        _wishlistStreamController.add(wishListItems);
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showRemoveAllConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Items>>(
        stream: _wishlistStreamController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return buildEmptyWishlist();
          }
          return buildWishlist(snapshot);
        },
      ),
    );
  }

  Widget buildEmptyWishlist() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/empty_wishlist.png', // Your image asset path
              height: 150.0,
              width: 150.0,
            ),
            SizedBox(height: 16.0),
            Text(
              "You haven't added any products yet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Click ',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                  WidgetSpan(
                    child: Icon(Icons.favorite, color: Colors.red, size: 16.0),
                  ),
                  TextSpan(
                    text: ' to save products',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopScreen()),
                );
              },
              child: Text("Find items to save"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWishlist(AsyncSnapshot<List<Items>> snapshot) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return buildWishlistItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWishlistItem(Items item) {
    return InkWell(
      onTap: () {
        // Navigate to the Item Details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemsDetailsScreen(model: item),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  API.getItemsImage + (item.thumbnailUrl ?? ''),
                  width: 130,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemTitle ?? 'Unnamed Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "₹ ${item.price}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      " ${item.itemInfo ?? 'Brand'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      " ${item.SizeName ?? ''}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      " ${item.ColourName ?? ''}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Add to Cart Functionality
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.yellow[700],
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text('Add to Cart'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
                onPressed: () {
                  showRemoveConfirmationDialog(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleWishlist(Items model, String userId) {
    setState(() {
      model.isWishListed = (model.isWishListed == "1" ? "0" : "1").toString();
    });
    // Emit a new event to the stream
    _wishlistStreamController.add(wishListItems);
    // You can update this in your backend or local database here
    updateWishlistInBackend(model, userId);
  }

  void updateWishlistInBackend(Items model, String userId) async {
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

  void showRemoveConfirmationDialog(BuildContext context, Items item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove from Wishlist"),
          content: Text(
              "Are you sure you want to remove this item from your wishlist?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                toggleWishlist(item, widget.userID);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showRemoveAllConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove All from Wishlist"),
          content: Text(
              "Are you sure you want to remove all items from your wishlist?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                removeAllWishlistItems(widget.userID);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void removeAllWishlistItems(String userId) async {
    const String apiUrl = API.wishListRemoveAll;
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'error') {
        print('Error removing all wishlist items: ${result['message']}');
      } else {
        print('All wishlist items removed: ${result['status']}');
        setState(() {
          wishListItems.clear();
        });

        // Emit a new event to the stream
        _wishlistStreamController.add(wishListItems);
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _wishlistStreamController.close();
    super.dispose();
  }
}
