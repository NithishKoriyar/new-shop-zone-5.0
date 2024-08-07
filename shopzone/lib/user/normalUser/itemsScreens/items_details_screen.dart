import 'dart:convert';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ItemsDetailsScreen extends StatefulWidget {
  final Items? model;

  ItemsDetailsScreen({this.model});

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  final CurrentUser currentUserController = Get.put(CurrentUser());
  List<Items> similarProducts = [];

  late String userName;
  late String userEmail;
  late String userID;
  late String userImg;
  int counterLimit = 1;

  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      printUserInfo();
      fetchSimilarProducts(widget.model!.variantID.toString());
      setState(() {});
    });
  }

  void setUserInfo() {
    userName = currentUserController.user.user_name;
    userEmail = currentUserController.user.user_email;
    userID = currentUserController.user.user_id.toString();
    userImg = currentUserController.user.user_profile;
  }

  void printUserInfo() {
    print('user Name: $userName');
    print('user Email: $userEmail');
    print('user ID: $userID');
    print('user image: $userImg');
  }

  Future<void> fetchSimilarProducts(String variantID) async {
    print('OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO');
    print(variantID);
    var url = Uri.parse("${API.fetchSimilarProducts}?variantID=$variantID");
    print(url);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["success"]) {
        setState(() {
          similarProducts = (jsonResponse["data"] as List)
              .map((item) => Items.fromJson(item))
              .toList();
        });
      } else {
        Fluttertoast.showToast(msg: jsonResponse["message"]);
      }
    } else {
      Fluttertoast.showToast(msg: "Network error.");
    }
  }

  void toggleWishlist(Items model, String userId) {
    setState(() {
      model.isWishListed = model.isWishListed == "1" ? "0" : "1";
    });
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
        'is_wishlisted': model.isWishListed == "1" ? '1' : '0',
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'error') {
        print('Error updating wishlist: ${result['message']}');
      } else {
        print('Wishlist status: ${result['status']}');
        showWishlistMessage(model.isWishListed == '1');
      }
    } else {
      print('Server error: ${response.statusCode}');
    }
  }

  void showWishlistMessage(bool isAdded) {
    Fluttertoast.showToast(
      msg: isAdded ? 'Item added to wishlist!' : 'Item removed from wishlist!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void shareItem(Items model) {
    final itemDetails = 'Check out this item: ${model.itemTitle}\n\n'
        'Price: ₹${model.price}\n\n'
        'Details: ${model.longDescription}\n\n'
        'Image: ${API.getItemsImage + (model.thumbnailUrl ?? '')}\n\n'
        'Link: https://www.google.com/${model.itemID}';

    Share.share(itemDetails);
  }

  @override
  Widget build(BuildContext context) {
    List<String?> imageUrls = [
      widget.model!.thumbnailUrl,
      widget.model!.secondImageUrl,
      widget.model!.thirdImageUrl,
      widget.model!.fourthImageUrl,
      widget.model!.fifthImageUrl,
    ];

    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Shop Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => CartScreenUser()));
            },
            icon: Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: () {
              shareItem(widget.model!);
            },
            icon: Icon(Icons.share),
          ),
        ],
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: () {
              int itemCounter = counterLimit;
              cartMethods.addItemToCart(
                widget.model!.itemID.toString(),
                itemCounter,
                userID,
              );
            },
            label: const Text("Add to Cart"),
            icon: const Icon(Icons.add_shopping_cart_rounded),
          ),
          FloatingActionButton.extended(
            backgroundColor: Colors.green,
            onPressed: () {
              int itemCounter = counterLimit;
              cartMethods.addItemToCart(
                widget.model!.itemID.toString(),
                itemCounter,
                userID,
              );
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => CartScreenUser()));
            },
            label: const Text("Buy Now"),
            icon: const Icon(Icons.credit_score_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 9.0,
                borderRadius: BorderRadius.circular(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 300, // Adjust height as needed
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: pageController,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            if (imageUrls[index] != null) {
                              return Hero(
                                tag: 'hero-${widget.model!.itemID}-$index',
                                child: Image.network(
                                  API.getItemsImage + (imageUrls[index] ?? ''),
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: imageUrls.length,
                              effect: ScrollingDotsEffect(
                                dotWidth: 8.0,
                                dotHeight: 8.0,
                                activeDotScale: 1.5,
                                activeDotColor: Colors.black,
                                dotColor: Colors.black.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    CartStepperInt(
                      count: counterLimit,
                      size: 50,
                      didChangeCount: (value) {
                        if (value < 1) {
                          Fluttertoast.showToast(
                              msg: "The quantity cannot be less than 1");
                          return;
                        }
                        setState(() {
                          counterLimit = value;
                        });
                      },
                    ),
                    const SizedBox(width: 20), // Adjust the width as needed
                    GestureDetector(
                      onTap: () {
                        toggleWishlist(widget.model!, userID);
                      },
                      child: Container(
                        child: Icon(
                          widget.model!.isWishListed == "1"
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.model!.isWishListed == "1"
                              ? Colors.orange
                              : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${widget.model!.itemTitle}",
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                widget.model!.itemInfo.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                widget.model!.longDescription.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "₹ ${widget.model!.price}",
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.green,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 320.0),
              child: Divider(
                height: 1,
                thickness: 2,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                'Select Size',
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.model!.SizeName?.map((size) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: selectedSize == size ? Colors.blue : Colors.white,
                        border: Border.all(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: selectedSize == size ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList() ?? [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                'Select Color',
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.model!.ColourName?.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: selectedColor == color ? Colors.blue : Colors.white,
                        border: Border.all(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: CircleAvatar(
                        backgroundColor: colorFromName(color),
                        radius: 20,
                      ),
                    ),
                  );
                }).toList() ?? [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Total Price: ₹ ${counterLimit * (double.tryParse(widget.model?.price ?? '0') ?? 0)}",
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Scrollable section for similar products
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Similar Products",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(
              height: 200, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarProducts.length,
                itemBuilder: (context, index) {
                  final item = similarProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemsDetailsScreen(model: item),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'hero-${item.itemID}',
                            child: Image.network(
                              API.getItemsImage + (item.thumbnailUrl ?? ''),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return const Text('Image not available');
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.itemTitle ?? '',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "₹ ${item.price}",
                              style: TextStyle(fontSize: 14, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color colorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'electric blue':
        return Colors.blue;
      case 'ochre':
        return Colors.brown;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'gray':
        return Colors.grey;
      case 'cyan':
        return Colors.cyan;
      case 'magenta':
        return Colors.pinkAccent;
      case 'lime':
        return Colors.lime;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
