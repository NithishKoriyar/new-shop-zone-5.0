import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';
import 'package:shopzone/user/normalUser/sellersScreens/ShopScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';


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

  @override
  void initState() {
    super.initState();
    fetchWishListItems(widget.userID); // Use widget.userID to access the userID property
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
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _showSelectSizeDialog(item);
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

 void _showSelectSizeDialog(Items item) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Image.network(
                      API.getItemsImage + (item.thumbnailUrl ?? ''),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: -13,
                      right: -10,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Color.fromARGB(255, 227, 29, 29),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemTitle ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "₹ ${item.price}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Select Size",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Please select a size to continue",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: item.SizeName?.map((size) {
                          return ChoiceChip(
                            label: Text(size),
                            selected: selectedSize == size,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedSize = size;
                              });
                            },
                          );
                        }).toList() ??
                            [],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: selectedSize != null
                        ? () {
                            Navigator.pop(context); // Close the dialog
                            // Proceed with the purchase
                            cartMethods.addItemToCart(
                              item.itemID.toString(),
                              1, // Assuming `counterLimit` to be 1, adjust as needed
                              widget.userID,
                              selectedSize!,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => CartScreenUser()),
                            );
                          }
                        : null,
                    child: Text("Continue"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


void _addToCart(Items item) async {
  if (selectedSize == null) {
    Fluttertoast.showToast(
      msg: "Please select a size",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(API.addToCart),  // Ensure API.addToCart is correctly defined
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': widget.userID,
        'item_id': item.itemID,
        'size': selectedSize,
        // Add other necessary parameters here
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        Fluttertoast.showToast(
          msg: "Added to cart with size: $selectedSize",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // After adding to cart, navigate to the cart screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartScreenUser(),  // Ensure CartScreenUser is correctly defined
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to add to cart: ${result['message']}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Server error: ${response.statusCode}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    print('Error adding to cart: $e');
    Fluttertoast.showToast(
      msg: "An error occurred",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
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
