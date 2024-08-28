import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class ShopScreen extends StatefulWidget {
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Items> itemsList = [];
  bool isLoadingMore = false;
  int itemsLoaded = 6;

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
      setState(() {});
    });
    restrictBlockedUsersFromUsingUsersApp();

    _scrollController.addListener(_onScroll);
    fetchInitialItems(); // Initial fetch
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      loadMoreItems(); // Fetch more items when scrolled to bottom
    }
  }

  Future<void> fetchInitialItems() async {
    try {
      // Fetch the first 6 items
      final response = await http.post(
        Uri.parse(API.displayItems),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userID, 'limit': itemsLoaded}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          itemsList = data.map((itemData) => Items.fromJson(itemData)).toList();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadMoreItems() async {
    setState(() {
      isLoadingMore = true;
    });

    try {
      // Load next set of items
      final response = await http.post(
        Uri.parse(API.displayItems),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userID,
          'limit': itemsLoaded,
          'offset': itemsList.length
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          itemsList.addAll(
              data.map((itemData) => Items.fromJson(itemData)).toList());
          isLoadingMore = false;
        });
      }
    } catch (e) {
      // Handle error
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => SearchScreen()));
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => CartScreenUser()));
            },
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Search Box
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
                          vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Image Slider
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

          // Category Section
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
          StreamBuilder<List<ShopCategory>>(
            stream: getCategoryStream(),
            builder: (context, AsyncSnapshot<List<ShopCategory>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return buildCategoryShimmer();
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 150,
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
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
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
                                  padding: EdgeInsets.all(5),
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

          // Top Sellers Section
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
          StreamBuilder<List<Sellers>>(
            stream: getSellersStream(),
            builder: (context, AsyncSnapshot<List<Sellers>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return buildSellersShimmer();
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    height: 150,
                    padding: EdgeInsets.all(5),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dataSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        Sellers model = dataSnapshot.data![index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => BrandsScreen(
                                  model: model,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
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
                                  padding: EdgeInsets.all(5),
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

          // Top Brands Section
          const SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child:
                      Text('Top Brands', style: TextStyle(color: Colors.grey))),
            ),
          ),
          StreamBuilder<List<Brands>>(
            stream: getBrandStream(),
            builder: (context, AsyncSnapshot<List<Brands>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return buildBrandsShimmer();
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
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
                                width: 70,
                                height: 70,
                                padding: EdgeInsets.all(5),
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
                              SizedBox(height: 5),
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
            padding: EdgeInsets.all(8.0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Recently Shortlisted by You',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Picked from your Wishlist',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        SizedBox(width: 8.0),
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
                              size: 16.0,
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
                return buildWishlistShimmer();
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                // Pick 3 random items from the wishlist
                List<Items> randomWishlistItems =
                    (dataSnapshot.data!..shuffle()).take(3).toList();

                return SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 228, 244, 252),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8.0),
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
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
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
                                builder: (c) =>
                                    ItemsDetailsScreen(model: item),
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
          const SliverPadding(
            padding: EdgeInsets.all(10),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child: Text('ExploreItems',
                      style: TextStyle(color: Colors.grey))),
            ),
          ),
        SliverGrid(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // 2 columns in the grid
    childAspectRatio: 0.75, // Adjust this ratio based on your design
    crossAxisSpacing: 5, // Space between columns
    mainAxisSpacing: 5, // Space between rows
  ),
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      if (index < itemsList.length) {
        Items model = itemsList[index];
        return buildItemCard(model); // Method to build your item widget
      } else if (isLoadingMore) {
        return Center(child: CircularProgressIndicator()); // Show loading indicator while loading more items
      } else {
        return Container(); // Return an empty container if no more items
      }
    },
    childCount: itemsList.length + (isLoadingMore ? 1 : 0),
  ),
),

        ],
      ),
    );
  }

 Widget buildItemCard(Items model) {
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
                width: double.infinity,
                height: 160,
                padding: EdgeInsets.all(8),
                child: model.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          API.getItemsImage + model.thumbnailUrl!,
                          fit: BoxFit.cover,
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
                style: TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
              Text(
                "₹ ${model.price.toString()}",
                style: TextStyle(fontSize: 15, color: Colors.green),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8, // Adjust these values to ensure the icon stays within the box
          child: GestureDetector(
            onTap: () {
              toggleWishlist(model, userID);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Optional: background color for better visibility
              ),
              padding: EdgeInsets.all(4), // Padding to increase the tap area
              child: Icon(
                model.isWishListed == "1"
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: model.isWishListed == "1" ? Colors.red : Colors.grey,
                size: 24, // Adjust the size of the icon if needed
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget buildCategoryShimmer() {
    return SliverToBoxAdapter(
      child: Container(
        height: 150,
        padding: EdgeInsets.all(5),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 10,
                      width: 60,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildSellersShimmer() {
    return SliverToBoxAdapter(
      child: Container(
        height: 150,
        padding: EdgeInsets.all(5),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 10,
                      width: 60,
                      color: Colors.white,
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 10,
                      width: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildBrandsShimmer() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
        childCount: 8,
      ),
    );
  }

  Widget buildWishlistShimmer() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: List.generate(3, (index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.white,
                ),
                title: Container(
                  height: 10,
                  color: Colors.white,
                ),
                subtitle: Container(
                  height: 10,
                  color: Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
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
