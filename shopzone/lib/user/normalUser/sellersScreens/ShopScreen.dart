import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopzone/api_key.dart';
import 'package:shopzone/notification_service.dart';
import 'package:shopzone/user/models/brands.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/shopcetogery.dart';
import 'package:shopzone/user/normalUser/brandsScreens/brands_screen.dart';
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/models/sellers.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_screen.dart';
import 'package:shopzone/user/normalUser/push_notifications/push_notifications_system.dart';
import 'package:shopzone/user/normalUser/searchScreen/search_screen.dart';

import 'package:shopzone/user/normalUser/subCetogoryScreens/SubcategoryScreen.dart';
import 'package:shopzone/user/normalUser/subCetogoryScreens/categoryScreen.dart';
import 'package:shopzone/user/normalUser/wishlist/wishlist_screen.dart';
import 'package:shopzone/user/normalUser/widgets/my_drawer.dart';
import 'package:shopzone/user/splashScreen/blocked_screen.dart';
import 'package:shopzone/user/splashScreen/my_splash_screen.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:shopzone/user/userPreferences/user_preferences.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class ShopScreen extends StatefulWidget {
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<dynamic> categories = [];
  final CurrentUser currentUserController = Get.put(CurrentUser());
  late String userID;
  bool dataLoaded = false;

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();

    notificationServices.requestNotificationPermissions();
    PushNotificationsSystem pushNotificationsSystem = PushNotificationsSystem();
    pushNotificationsSystem.whenNotificationReceived(context);
    pushNotificationsSystem.generateDeviceRecognitionToken();
    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      printUserInfo();
      // Once the seller info is set, call setState to trigger a rebuild.
      setState(() {});
    });
    restrictBlockedUsersFromUsingUsersApp();
    getSellersStream();
    getCategoryStream();
  }

  void setUserInfo() {
    userID = currentUserController.user.user_id.toString();
    dataLoaded = true;
  }

  void printUserInfo() {
    print('user ID ----------------: $userID');
  }

  restrictBlockedUsersFromUsingUsersApp() async {
    await Future.delayed(Duration(milliseconds: 500)); // Ensure userID is set
    print('user ID ----------------: $userID');
    if (userID != null && userID.isNotEmpty) {
      try {
        var res = await http.post(
          Uri.parse(API.checkUserStatus),
          body: {
            "user_id": userID,
          },
        );

        if (res.statusCode == 200) {
          var resBody = jsonDecode(res.body);

          if (resBody['success'] == true) {
            if (resBody['status'] == 'approved') {
              // User is approved
              // Add your logic here if needed
            } else {
              // User is blocked
              print("blocked user-------------------");
              Fluttertoast.showToast(msg: resBody['message']);
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (c) => BlockedScreen()));
            }
          } else {
            Fluttertoast.showToast(msg: resBody['message']);
            Navigator.pop(context);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (c) => BlockedScreen()));
          }
        } else {
          Fluttertoast.showToast(
              msg: "Error: Unable to communicate with server.");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      }
    } else {
      Fluttertoast.showToast(msg: "User ID is missing.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set the user information

    return Scaffold(
      backgroundColor: Colors.white10,
      drawer: MyDrawer(),
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Shop Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => SearchScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            color: Colors.red,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => WishListScreen(userID: userID)));
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (c) => CartScreenUser()));
              // Handle cart action
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          //...........
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
                child: IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for Products, Brands and More',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20), // Adjust the padding here
                    ),
                    onSubmitted: (String query) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          //..........................
          //image slider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blueAccent.withOpacity(0.3)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * .9,
                      aspectRatio: 16 / 8,
                      viewportFraction: 0.44,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                    items: itemsImagesList.map((index) {
                      return Builder(builder: (BuildContext c) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  index,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black45,
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(color: Colors.grey),
                    ),
                    InkWell(
                      onTap: () {
                        //Navigate to the screen that shows all categories
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //displyaing categories section
          StreamBuilder<List<ShopCategory>>(
            stream: getCategoryStream(),
            builder: (context, AsyncSnapshot<List<ShopCategory>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 150, // Set the height of the container
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dataSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        ShopCategory model = dataSnapshot.data![index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubCategoryScreen(
                                  categoryId: model.category_id.toString(),
                                  categoryName: model.name.toString(),
                                  categoryImg: model.file_path.toString(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            width: 80, // Set the width for each seller's widget
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100, // Diameter of the circle
                                  height: 100, // Diameter of the circle
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors
                                        .white, // Background color of the circle
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 69, 69, 69)
                                            .withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(
                                      5), // Padding for the circle
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(API.normalImage +
                                            model.file_path.toString()),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  model.name.toString(),
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Sellers Data exists."),
                  ),
                );
              }
            },
          ),

//................................
          SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child: Text(
                'Top Sellers',
                style: TextStyle(color: Colors.grey),
              )),
            ),
          ),

          ///...............circes in shop name
          StreamBuilder<List<Sellers>>(
            stream: getSellersStream(),
            builder: (context, AsyncSnapshot<List<Sellers>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 150, // Set the height of the container
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dataSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        Sellers model = dataSnapshot.data![index];
                        return InkWell(
                          onTap: () {
                            // Perform your action on tap!
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => BrandsScreen(
                                  model: model,
                                ),
                              ),
                            );
                            // You can navigate to a new page or display a dialog, etc.
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            width: 80, // Set the width for each seller's widget
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100, // Diameter of the circle
                                  height: 100, // Diameter of the circle
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors
                                        .white, // Background color of the circle
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 69, 69, 69)
                                            .withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(
                                      5), // Padding for the circle
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(API.sellerImage +
                                            model.sellerProfile),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  model.sellerName,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                                SmoothStarRating(
                                  // ignore: unnecessary_null_comparison
                                  rating: model.rating == null
                                      ? 0.0
                                      : double.parse(model.rating.toString()),
                                  starCount: 5,
                                  color: Colors.pinkAccent,
                                  borderColor: Colors.pinkAccent,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Sellers Data exists."),
                  ),
                );
              }
            },
          ),

          const SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child:
                      Text('Top Brands', style: TextStyle(color: Colors.grey))),
            ),
          ),

          ///...............displying 16 brand products

          StreamBuilder<List<Brands>>(
            stream: getBrandStream(),
            builder: (context, AsyncSnapshot<List<Brands>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns
                    childAspectRatio:
                        0.75, // Ratio of the width to the height of each cell
                    crossAxisSpacing: 10, // Horizontal space between cells
                    mainAxisSpacing: 10, // Vertical space between cells
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Brands model = dataSnapshot.data![index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => ItemsScreen(
                                        model: model,
                                      )));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width:
                                    70, // You might need to adjust this based on your padding
                                height:
                                    70, // Same as above, adjust if necessary
                                padding: EdgeInsets.all(
                                    5), // Adjust the padding value as needed
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        API.brandImage +
                                            (model.thumbnailUrl ?? ''),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height:
                                      5), // Space between the image and the text
                              Text(
                                model.brandTitle.toString(),
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: dataSnapshot.data!.length,
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Sellers Data exists."),
                  ),
                );
              }
            },
          ),

// Wishlist Section
          SliverPadding(
            padding:
                EdgeInsets.all(8.0), // Increased padding for overall spacing
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Use min size to fit content
                  children: <Widget>[
                    Text(
                      'Recently Shortlisted by You',
                      style: TextStyle(
                        fontSize: 20.0, // Larger font size for the header
                        fontWeight: FontWeight.bold, // Bold font weight
                        color: Color(
                            0xFF757575), // Dark grey, equivalent to grey[600]
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Picked from your Wishlist',
                          style: TextStyle(
                            fontSize: 16.0, // Slightly smaller font size
                            color: Color(
                                0xFF9E9E9E), // Light grey, equivalent to grey[500]
                          ),
                        ),
                        SizedBox(
                            width:
                                8.0), // Add some spacing between text and icon
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WishListScreen(
                                        userID: userID,
                                      )),
                            );
                          },
                          child: CircleAvatar(
                            radius: 12.0,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 16.0, // Adjust icon size as needed
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          StreamBuilder<List<Items>>(
            stream: getWishListItemsStream(userID),
            builder: (context, AsyncSnapshot<List<Items>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                // Pick 3 random items from the wishlist
                List<Items> randomWishlistItems =
                    (dataSnapshot.data!..shuffle()).take(3).toList();

                return SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                          255, 228, 244, 252), // Ash grey background color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26, // Shadow color
                          blurRadius: 10.0, // Shadow blur radius
                          offset: Offset(0, 4), // Shadow offset
                        ),
                      ],
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional: Rounded corners
                    ),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: randomWishlistItems.map((item) {
                        return ListTile(
                          leading: Image.network(
                            API.getItemsImage + (item.thumbnailUrl ?? ''),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            item.itemTitle ?? '',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemInfo ?? '',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                "₹ ${item.price}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.green),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => ItemsDetailsScreen(model: item),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Wishlist Items exist."),
                  ),
                );
              }
            },
          ),

          // Items Section
          ///items---------------------------------------------------------------
          const SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child: Text('ExploreItems',
                      style: TextStyle(color: Colors.grey))),
            ),
          ),

          StreamBuilder<List<Items>>(
            stream: getItemStream(userID),
            builder: (context, AsyncSnapshot<List<Items>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Items model = dataSnapshot.data![index];
                      String? thumbnailUrl = model.thumbnailUrl;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => ItemsDetailsScreen(model: model),
                            ),
                          );
                        },
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
                            // Heart-shaped wishlist icon
                            Positioned(
                              top: 0.7,
                              right: 7,
                              child: GestureDetector(
                                onTap: () {
                                  // Toggle the wishlist state
                                  print(model.isWishListed);
                                  toggleWishlist(model, userID);
                                },
                                child: Container(
                                  child: Icon(
                                    model.isWishListed == "1"
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: model.isWishListed == "1"
                                        ? Colors.red
                                        : Colors.red,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: dataSnapshot.data!.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Items Data exists."),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  Future<List<String>> fetchImages() async {
    final response = await http.get(Uri.parse(API.imageSlider));

    if (response.statusCode == 200) {
      List<dynamic> imagesJson = jsonDecode(response.body);
      return imagesJson.map((image) => image.toString()).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  Stream<List<Sellers>> getSellersStream() async* {
    final response = await http.get(Uri.parse(API.sellerNameBrand));
    print(API.fetchCategories);

    if (response.statusCode == 200) {
      final sellersList = json.decode(response.body) as List;
      final sellersObjects =
          sellersList.map((item) => Sellers.fromJson(item)).toList();
      yield sellersObjects;
    } else {
      throw Exception('Failed to load sellers');
    }
  }

  Stream<List<Items>> getItemStream(String userId) async* {
    final response = await http.post(
      Uri.parse(API.displayItems),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      yield data.map((itemData) => Items.fromJson(itemData)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

// Fetch wishlist items
  Stream<List<Items>> getWishListItemsStream(String userId) async* {
    final response =
        await http.get(Uri.parse('${API.fetchWishListItems}?userID=$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      yield data.map((item) => Items.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load wishlist items');
    }
  }

  // Displaying 16 brands
  Stream<List<Brands>> getBrandStream() async* {
    final response = await http.get(Uri.parse(API.display16Brands));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      yield data.map((brandData) => Brands.fromJson(brandData)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  Stream<List<ShopCategory>> getCategoryStream() async* {
    final response = await http.get(Uri.parse(API.fetchCategories));
    print(API.fetchCategories);

    if (response.statusCode == 200) {
      final sellersList = json.decode(response.body) as List;
      final sellersObjects =
          sellersList.map((item) => ShopCategory.fromJson(item)).toList();
      yield sellersObjects;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void toggleWishlist(Items model, userId) {
    setState(() {
      model.isWishListed = (model.isWishListed == "1" ? "0" : "1").toString();
    });
    // Emit a new event to the stream
    // _wishlistStreamController.add(wishListItems);

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
}
