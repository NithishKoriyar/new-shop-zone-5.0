import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
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
import 'package:shopzone/user/normalUser/wishlist/wishlist_screen.dart';
import 'package:shopzone/user/normalUser/widgets/my_drawer.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class ShopScreen extends StatefulWidget {
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<dynamic> categories = [];
  restrictBlockedUsersFromUsingUsersApp() async {
    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(sharedPreferences!.getString("uid"))
    //     .get().then((snapshot)
    // {
    //   if(snapshot.data()!["status"] != "approved")
    //   {
    //     showReusableSnackBar(context, "you are blocked by admin.");
    //     showReusableSnackBar(context, "contact admin: admin2@jan-G-shopy.com");

    //     FirebaseAuth.instance.signOut();
    //     Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
    //   }
    //   else
    //   {
    //     cartMethods.clearCart(context);
    //   }
    // });
  }
  //!notification Services requesting
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    super.initState();
    //!notification Services requesting
    notificationServices.requestNotificationPermissions();
    PushNotificationsSystem pushNotificationsSystem = PushNotificationsSystem();
    pushNotificationsSystem.whenNotificationReceived(context);
    pushNotificationsSystem.generateDeviceRecognitionToken();

    restrictBlockedUsersFromUsingUsersApp();
    getSellersStream();
    getCategoryStream();
    // getSubCategoryStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (c) => FavoriteScreen()));
              
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
                Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => CartScreenUser()));
              // Handle cart action
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
       //image slider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * .9,
                    aspectRatio: 16 / 8,
                    viewportFraction: 0.8,
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
                        margin: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            index,
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
            ),
          ),


     

          SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child: Text(
                'category',
                style: TextStyle(color: Colors.grey),
              )),
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

          SliverPadding(
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
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          margin: EdgeInsets.all(5),
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
            stream: getItemStream(),
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
                    crossAxisCount: 2, // Number of columns
                    childAspectRatio:
                        0.75, // Ratio of the width to the height of each cell
                    crossAxisSpacing: 10, // Horizontal space between cells
                    mainAxisSpacing: 10, // Vertical space between cells
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Items model = dataSnapshot.data![index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => ItemsDetailsScreen(
                                        model: model,
                                      )));
                        },
                        child: Container(
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
                                width:
                                    170, // You might need to adjust this based on your padding
                                height:
                                    160, // Same as above, adjust if necessary
                                padding: EdgeInsets.all(
                                    8), // Adjust the padding value as needed

                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        API.getItemsImage +
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
                                model.itemTitle.toString(),
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                              ),
                              Text(
                                model.itemInfo.toString(),
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
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
                      );
                    },
                    childCount: dataSnapshot.data!.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Sellers Data exists."),
                  ),
                );
              }
            },
          ),

          // StreamBuilder<List<Sellers>>(
          //   stream: getSellersStream(),
          //   builder: (context, AsyncSnapshot<List<Sellers>> dataSnapshot) {
          //     if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
          //       return SliverStaggeredGrid.countBuilder(
          //         crossAxisCount: 1,
          //         staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
          //         itemBuilder: (context, index) {
          //           Sellers model = dataSnapshot.data![index];

          //           return SellersUIDesignWidget(
          //             model: model,
          //           );
          //         },
          //         itemCount: dataSnapshot.data!.length,
          //       );
          //     } else {
          //       return const SliverToBoxAdapter(
          //         child: Center(
          //           child: Text(
          //             "No Sellers Data exists.",
          //           ),
          //         ),
          //       );
          //     }
          //   },
          // ),
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
      // print("-----------------------------=======---------------------------");
      // print(sellersList);
      // print(sellersObjects);
    } else {
      throw Exception('Failed to load sellers');
    }
  }

//displying 16 brand
  Stream<List<Brands>> getBrandStream() async* {
    final response = await http.get(Uri.parse(API.display16Brands));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      yield data.map((brandData) => Brands.fromJson(brandData)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  //item
  Stream<List<Items>> getItemStream() async* {
    final response = await http.get(Uri.parse(API.displayItems));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      yield data.map((brandData) => Items.fromJson(brandData)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  // Future<void> fetchCategories() async {
  //   final response = await http.get(Uri.parse(API.fetchCategories));

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       categories = json.decode(response.body);
  //     });
  //     print(
  //         '-----------------------------------------------------------------');
  //     print(categories);
  //   } else {
  //     throw Exception('Failed to fetch categories');
  //   }
  // }

  //category
  Stream<List<ShopCategory>> getCategoryStream() async* {
    final response = await http.get(Uri.parse(API.fetchCategories));
    print(API.fetchCategories);

    if (response.statusCode == 200) {
      final sellersList = json.decode(response.body) as List;
      final sellersObjects =
          sellersList.map((item) => ShopCategory.fromJson(item)).toList();
      yield sellersObjects;
      // print("-----------------------------=======---------------------------");
      // print(sellersList);
      // print(sellersObjects);
    } else {
      throw Exception('Failed to load sellers');
    }
  }

  //sub
  // Stream<List<Items>> getSubCategoryStream() async* {
  //   final response = await http.get(Uri.parse(API.fetchSubCategories));
  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);

  //     yield data.map((brandData) => Items.fromJson(brandData)).toList();
  //   } else {
  //     throw Exception('Failed to load brands');
  //   }
  // }
}
