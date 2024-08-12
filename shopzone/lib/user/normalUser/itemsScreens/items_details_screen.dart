import 'dart:convert';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/normalUser/searchScreen/search_screen.dart';
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
    // Add a boolean to track if the item is added to cart
  bool isAddedToCart = false;

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
    // Initialize the selected size and color based on the initial item's attributes
    selectedSize = widget.model!.SizeName?.first;
    selectedColor = widget.model!.ColourName?.first;
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
    print('Fetching similar products...');
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
      backgroundColor: Color.fromARGB(255, 232, 230, 235),
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search for products',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            filled: true,
            fillColor: Color.fromARGB(255, 231, 227, 227),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          onTap: () {
            // Navigate immediately to the SearchScreen without buffering
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => CartScreenUser()));
            },
            icon: Icon(Icons.shopping_cart),
          ),
        ],
        centerTitle: true,
        automaticallyImplyLeading: true,
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
                    height: 480, // Adjust height as needed
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: pageController,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            if (imageUrls[index] != null) {
                              return Hero(
                                tag: 'hero-${widget.model!.itemID}-$index',
                                child: Stack(
                                  children: [
                                    Image.network(
                                      API.getItemsImage +
                                          (imageUrls[index] ?? ''),
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: GestureDetector(
                                        onTap: () {
                                          toggleWishlist(widget.model!, userID);
                                        },
                                        child: Icon(
                                          widget.model!.isWishListed == "1"
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              widget.model!.isWishListed == "1"
                                                  ? Colors.orange
                                                  : Colors.grey,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
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
//           Padding(
//   padding: const EdgeInsets.all(10.0),
//   child: Container(
//     decoration: BoxDecoration(
//       color: Colors.blueGrey.shade50,
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.5),
//           spreadRadius: 2,
//           blurRadius: 5,
//           offset: Offset(0, 3),
//         ),
//       ],
//     ),
//     padding: const EdgeInsets.all(8.0),
//     child: Row(
//       children: [
//         Icon(Icons.trending_up, color: Colors.blueGrey),
//         SizedBox(width: 8),
//         Text(
//           "Similar Products",
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.blueGrey,
//           ),
//         ),
//       ],
//     ),
//   ),
// ),

            Container(
              child: SizedBox(
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
                            builder: (context) =>
                                ItemsDetailsScreen(model: item),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                color: Colors.transparent,
                                child: Image.network(
                                  API.getItemsImage + (item.thumbnailUrl ?? ''),
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.itemTitle ?? '',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                "₹ ${item.price}",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                'Color: $selectedColor',
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: colorFromName(color),
                              radius: 20,
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                'Size: $selectedSize',
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                              color: selectedSize == size
                                  ? Colors.black
                                  : Colors.white,
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              size,
                              style: TextStyle(
                                color: selectedSize == size
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList() ??
                      [],
                ),
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
          ],
        ),
      ),
   bottomNavigationBar: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!isAddedToCart) {
                    int itemCounter = counterLimit;
                    cartMethods.addItemToCart(
                      widget.model!.itemID.toString(),
                      itemCounter,
                      userID,
                    );
                    setState(() {
                      isAddedToCart = true;
                    });
                  } else {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (c) => CartScreenUser()));
                  }
                },
                child: Container(
                  height: 50,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    isAddedToCart ? "Go to cart" : "Add to cart",
                    style: TextStyle(
                      color: isAddedToCart ? Colors.black : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  int itemCounter = counterLimit;
                  cartMethods.addItemToCart(
                    widget.model!.itemID.toString(),
                    itemCounter,
                    userID,
                  );
                  Navigator.push(
                      context, MaterialPageRoute(builder: (c) => CartScreenUser()));
                },
                child: Container(
                  height: 50,
                  color: Color.fromARGB(255, 148, 134, 5),
                  alignment: Alignment.center,
                  child: Text(
                    "Buy now",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
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
