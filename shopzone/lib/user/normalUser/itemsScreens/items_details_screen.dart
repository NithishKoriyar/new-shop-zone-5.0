import 'dart:convert';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/normalUser/itemsScreens/seller_products_screen.dart';
import 'package:shopzone/user/normalUser/itemsScreens/singleseller_product.dart';
import 'package:shopzone/user/normalUser/searchScreen/search_screen.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class ItemsDetailsScreen extends StatefulWidget {
  final Items? model;

  ItemsDetailsScreen({this.model});

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  final CurrentUser currentUserController = Get.put(CurrentUser());
  List<Items> similarProducts = [];
  List<Items> sellerProducts = []; // List to store seller's other products
  bool isAddedToCart = false;

  late String userName;
  late String userEmail;
  late String userID;
  late String userImg;
  int counterLimit = 1;

  String? selectedSize;
  String? initialSelectedSize;
  String? selectedColor;
  String sellerName = '';
  String sellerProfile = '';
  double sellerRating = 0.0;

  bool isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      printUserInfo();
      fetchSimilarProducts(widget.model!.variantID.toString());
      fetchSellerInfo(widget.model!.sellerUID.toString());
      fetchSellerProducts(); // Fetch seller's other products
      setState(() {
        isLoading = false; // Stop loading after fetching data
      });
    });
    selectedSize = widget.model!.SizeName?.first;
    initialSelectedSize = selectedSize;
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
    var url = Uri.parse("${API.fetchSimilarProducts}?variantID=$variantID");

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

  Future<void> fetchSellerProducts() async {
    var url = Uri.parse("${API.displayItemss}");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userID,
        'seller_id': widget.model!.sellerUID,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      List<Items> allSellerProducts =
          (jsonResponse as List).map((item) => Items.fromJson(item)).toList();

      // Shuffle the items to get a random selection
      allSellerProducts.shuffle();

      setState(() {
        // Display up to 6 random items
        sellerProducts = allSellerProducts.take(6).toList();
      });
    } else {
      Fluttertoast.showToast(msg: "Failed to load seller's products.");
    }
  }

  Future<void> fetchSellerInfo(String? sellerID) async {
    if (sellerID == null) return;

    final url = Uri.parse("${API.fetchSellerInfo}?sellerID=$sellerID");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

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

  void _showSelectSizeDialog() {
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
                      // Product Image
                      Image.network(
                        API.getItemsImage + (widget.model?.thumbnailUrl ?? ''),
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
                        // Product Title
                        Text(
                          widget.model?.itemTitle ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Product Price
                        Text(
                          "₹ ${widget.model?.sellingPrice}",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Select Size Text
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
                        // Available Sizes
                        Wrap(
                          spacing: 10,
                          children: widget.model?.SizeName?.map((size) {
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
                                widget.model!.itemID.toString(),
                                counterLimit,
                                userID,
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

  String _calculateDiscount(String originalPrice, String sellingPrice) {
    double original = double.parse(originalPrice);
    double selling = double.parse(sellingPrice);
    double discount = ((original - selling) / original) * 100;
    return "-${discount.toStringAsFixed(0)}%";
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
                    height: 480,
                    child: Stack(
                      children: [
                        isLoading
                            ? _buildShimmerEffect() // Display shimmer while loading
                            : PageView.builder(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Color: ',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '$selectedColor',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            widget.model!.ColourName?.toSet().map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedColor = color;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      padding: const EdgeInsets.all(1.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: selectedColor == color
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 0.1,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: colorFromName(color),
                                        radius: 15,
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 150,
                child: similarProducts.isNotEmpty
                    ? ListView.builder(
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
                            child: buildProductCard(item),
                          );
                        },
                      )
                    : sellerProducts.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: sellerProducts.length,
                            itemBuilder: (context, index) {
                              final item = sellerProducts[index];
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
                                child: buildProductCard(item),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                                "No similar products or seller products found."),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${widget.model!.itemTitle}",
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                       Spacer(),
                  IconButton(
                    icon: Icon(
                      widget.model!.isWishListed == "1"
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.model!.isWishListed == "1"
                          ? Color.fromARGB(255, 213, 9, 9)
                          : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      toggleWishlist(widget.model!, userID);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.blueGrey,
                      size: 28,
                    ),
                    onPressed: () {
                      shareItem(widget.model!);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  if (widget.model!.sellingPrice != null)
                    Text(
                      "₹${widget.model!.sellingPrice}", // Selling price in bold green
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.green,
                      ),
                    ),
                  SizedBox(width: 10), // Space between prices
                  if (widget.model!.price != null)
                    Text(
                      "₹${widget.model!.price}", // Original price with strike-through
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  SizedBox(width: 10), // Space between prices and discount
                  if (widget.model!.price != null && widget.model!.sellingPrice != null)
                    Text(
                      _calculateDiscount(widget.model!.price!, widget.model!.sellingPrice!), // Discount percentage
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
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
                                    : Colors.blueGrey,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CartStepperInt(
                      count: counterLimit,
                      size: 40,
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
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: ExpandableText(
                text: widget.model!.itemInfo ?? '',
                maxLines: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: ExpandableText(
                text: widget.model!.longDescription ?? '',
                maxLines: 2,
              ),
            ),
            Divider(thickness: 1, color: Colors.grey),

            // Seller info section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sold by',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          API.sellerImage + sellerProfile,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              SizedBox(width: 5),
                              SmoothStarRating(
                                rating: sellerRating == null
                                    ? 0.0
                                    : double.parse(sellerRating.toString()),
                                starCount: 5,
                                color: Colors.pinkAccent,
                                borderColor: Colors.pinkAccent,
                                size: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerProductsScreen(
                                sellerID: widget.model!.sellerUID.toString(),
                                userID: userID,
                                sellerName: sellerName,
                                sellerProfile: sellerProfile,
                                sellerRating: sellerRating.toString(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 218, 157, 228),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('View Shop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider after seller info
            Divider(thickness: 4, color: Colors.grey),

            // "You May Also Like" section
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You May Also Like',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerItemsScreen(
                            sellerID: widget.model!.sellerUID.toString(),
                            userID: userID,
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Display up to 6 seller's random items
           Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 220, // Adjust the height according to your design
                child: sellerProducts.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sellerProducts.length,
                        itemBuilder: (context, index) {
                          final item = sellerProducts[index];
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
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.zero, // Sharp edges
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    API.getItemsImage + item.thumbnailUrl.toString(),
                                    height: 120, // Adjust according to your design
                                    width: 120, // Adjust according to your design
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 5.0,
                                    ),
                                    child: Container(
                                      width: 100, // Constrain the width of the title
                                      child: Text(
                                        item.itemTitle.toString(),
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Text(
                                      "₹${item.sellingPrice}",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text("No items found from this seller."),
                      ),
              ),
            )

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
                  if (selectedSize == initialSelectedSize) {
                    _showSelectSizeDialog(); // Show the dialog if size hasn't been changed
                  } else {
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => CartScreenUser()));
                    }
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
                  if (selectedSize == initialSelectedSize) {
                    _showSelectSizeDialog(); // Show the dialog if size hasn't been changed
                  } else {
                    int itemCounter = counterLimit;
                    cartMethods.addItemToCart(
                      widget.model!.itemID.toString(),
                      itemCounter,
                      userID,
                    
                    
                    );
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => CartScreenUser()));
                  }
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

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 480,
        color: Colors.white,
      ),
    );
  }

  Widget buildProductCard(Items item) {
    return Container(
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
              maxLines: 1, // Limit to one line
              overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              "₹ ${item.sellingPrice}",
              style: TextStyle(fontSize: 14, color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  ExpandableText({required this.text, this.maxLines = 2});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: LayoutBuilder(
        builder: (context, size) {
          final span = TextSpan(
            text: widget.text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          );

          final tp = TextPainter(
            text: span,
            maxLines: widget.maxLines,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          );

          tp.layout(maxWidth: size.maxWidth);

          if (tp.didExceedMaxLines) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isExpanded
                      ? widget.text
                      : widget.text.substring(
                              0,
                              tp
                                  .getPositionForOffset(Offset(size.maxWidth,
                                      tp.height * widget.maxLines))
                                  .offset) +
                          '...',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _isExpanded ? "Show less" : "Show more",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 202, 218, 232),
                  ),
                ),
              ],
            );
          } else {
            return Text(
              widget.text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            );
          }
        },
      ),
    );
  }
}
