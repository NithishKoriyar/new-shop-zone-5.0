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
    fetchWishListItems(widget.userID);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Wish List Items", style: TextStyle(fontSize: screenWidth * 0.05)),
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
            return buildEmptyWishlist(screenWidth, screenHeight);
          }
          return buildWishlist(snapshot, screenWidth, screenHeight);
        },
      ),
    );
  }

  Widget buildEmptyWishlist(double screenWidth, double screenHeight) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/empty_wishlist.png', // Your image asset path
              height: screenHeight * 0.2,
              width: screenWidth * 0.3,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "You haven't added any products yet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey),
            ),
            SizedBox(height: screenHeight * 0.01),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Click ',
                    style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                  ),
                  WidgetSpan(
                    child: Icon(Icons.favorite, color: Colors.red, size: screenWidth * 0.04),
                  ),
                  TextSpan(
                    text: ' to save products',
                    style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopScreen()),
                );
              },
              child: Text("Find items to save", style: TextStyle(fontSize: screenWidth * 0.04)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWishlist(AsyncSnapshot<List<Items>> snapshot, double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.025),
        child: Column(
          children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return buildWishlistItem(item, screenWidth, screenHeight);
              },
            ),
          ],
        ),
      ),
    );
  }

Widget buildWishlistItem(Items item, double screenWidth, double screenHeight) {
    return InkWell(
        onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ItemsDetailsScreen(model: item),
                ),
            );
        },
        child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            elevation: 4.0,
            child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            child: Image.network(
                                API.getItemsImage + (item.thumbnailUrl ?? ''),
                                width: screenWidth * 0.3,
                                height: screenHeight * 0.25,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                            ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        item.itemTitle ?? 'Unnamed Item',
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    if (item.sellingPrice != null)
                                        Row(
                                            children: [
                                                Text(
                                                    "₹${item.sellingPrice}",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: screenWidth * 0.035,
                                                        color: Colors.green,
                                                    ),
                                                ),
                                                SizedBox(width: screenWidth * 0.01),
                                                if (item.price != null)
                                                    Text(
                                                        "₹${item.price}",
                                                        style: TextStyle(
                                                            fontSize: screenWidth * 0.045,
                                                            color: Colors.grey,
                                                            decoration: TextDecoration.lineThrough,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                    ),
                                                SizedBox(width: screenWidth * 0.01),
                                                if (item.price != null && item.sellingPrice != null)
                                                    Text(
                                                        _calculateDiscount(item.price!, item.sellingPrice!),
                                                        style: TextStyle(
                                                            fontSize: screenWidth * 0.045,
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                        ),
                                                    ),
                                            ],
                                        ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Text(
                                        "${item.itemInfo ?? 'Brand'}",
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: screenHeight * 0.04),
                                    ElevatedButton(
                                        onPressed: () {
                                            _showSelectSizeDialog(item, screenWidth, screenHeight);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor: Colors.yellow[700],
                                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                                        ),
                                        child: Text('Add to Cart', style: TextStyle(fontSize: screenWidth * 0.04)),
                                    ),
                                ],
                            ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
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


String _calculateDiscount(String originalPrice, String sellingPrice) {
  double original = double.parse(originalPrice);
  double selling = double.parse(sellingPrice);
  double discount = ((original - selling) / original) * 100;
  return "-${discount.toStringAsFixed(0)}%";
}

 void _showSelectSizeDialog(Items item, double screenWidth, double screenHeight) {
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
                        "₹ ${item.sellingPrice}",
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
