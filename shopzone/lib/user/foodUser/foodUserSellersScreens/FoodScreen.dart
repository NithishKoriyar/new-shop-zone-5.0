import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/notification_service.dart';
import 'package:shopzone/user/foodUser/foodUserBrandsScreens/brands_screen.dart';
import 'package:shopzone/user/foodUser/foodUserGlobal/global.dart';
import 'package:shopzone/user/foodUser/foodUserItemsScreens/items_details_screen.dart';
import 'package:shopzone/user/foodUser/foodUserItemsScreens/items_screen.dart';
import 'package:shopzone/user/models/brands.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/sellers.dart';
import 'package:shopzone/user/foodUser/foodUserPush_notifications/push_notifications_system.dart';
import 'package:shopzone/user/foodUser/foodUserWidgets/my_drawer.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

// ignore: must_be_immutable
class FoodScreen extends StatefulWidget {
  Brands? model;

  BuildContext? context;

  FoodScreen({
    this.model,
  });
  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
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
  final CurrentUser currentUserController = Get.put(CurrentUser());

  late String userID;

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
    //!user Information
    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      updateLocation();
      setState(() {});
    });
  }

  void setUserInfo() {
    userID = currentUserController.user.user_id.toString();
  }

  //!user location update
  void updateLocation() async {
    try {
      Position position = await getCurrentLocation();
      await sendLocationToServer(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Food Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          //image slider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .3,
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * .9,
                    aspectRatio: 16 / 9,
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
                          borderRadius: BorderRadius.circular(40),
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

          //query
          //model
          //i want display text here that " hotels near by you"
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Hotels nearby you",
                style: TextStyle(
                  fontSize: 24, // You can adjust the font size as needed
                  fontWeight: FontWeight.bold,
                  // Other text styling options...
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          //....................................................................................nithizz
          SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Center(
                  child: Text(
                'Top Restaurants',
                style: TextStyle(color: Colors.grey),
              )),
            ),
          ),
//..............
          StreamBuilder<List<Sellers>>(
  stream: getSellersStream(),
  builder: (context, AsyncSnapshot<List<Sellers>> dataSnapshot) {
    if (dataSnapshot.connectionState == ConnectionState.waiting) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 150, // Set the height of the container
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dataSnapshot.data!.length,
            itemBuilder: (context, index) {
              Sellers model = dataSnapshot.data![index];
              return InkWell(
                onTap: () {
                  print("Rating...");

                  //send user to a seller's brands screen
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
                  width: 80, // Set the width for each seller's widget
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, // Diameter of the circle
                        height: 100, // Diameter of the circle
                        padding: EdgeInsets.all(5), // Padding for the circle
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white, // Background color of the circle
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 69, 69, 69).withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(API.foodSellerImageInFoodUser + model.sellerProfile),
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
                        rating: model.rating == null ? 0.0 : double.parse(model.rating.toString()),
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
                      Text('Top Menus', style: TextStyle(color: Colors.grey))),
            ),
          ),
//.........................................displyaying menus..................................................................
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
                                  builder: (c) => ItemsScreen(model: model)));
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
                                        API.foodSellerBrandImage +
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
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Sellers Data exists."),
                  ),
                );
              }
            },
          ),

//......................................viewitems..........................................
          SliverPadding(
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
                                        API.foodSellerMenuItemsInFoodUser +
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

//.....................................................................................
          // StreamBuilder<List<Sellers>>(
          //   stream: getSellersStream(),
          //   builder: (context, AsyncSnapshot<List<Sellers>> dataSnapshot) {
          //     // Check if the snapshot is still fetching data
          //     if (dataSnapshot.connectionState == ConnectionState.waiting) {
          //       // Show loading indicator while fetching data
          //       return SliverFillRemaining(
          //         child: Center(
          //           child: CircularProgressIndicator(),
          //         ),
          //       );
          //     } else if (dataSnapshot.hasData &&
          //         dataSnapshot.data!.isNotEmpty) {
          //       // Data is fetched and not empty, show your content
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
          //       // Data is fetched but empty, show a message
          //       return const SliverToBoxAdapter(
          //         child: Center(
          //           child: Text(
          //             "No Sellers Data exists.",
          //           ),
          //         ),
          //       );
          //     }
          //   },
          // )
        ],
      ),
    );
  }

  Stream<List<Sellers>> getSellersStream() async* {
    try {
      // Obtain the current location
      Position position = await getCurrentLocation();
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Construct the URL with latitude and longitude in the path
      String baseUrl = API.fetchSellerByFoodUser;
      var url = Uri.parse(baseUrl).replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });
      print(url);

      final response = await http.get(url);

      // Check for a successful response
      if (response.statusCode == 200) {
        final sellersList = json.decode(response.body) as List;
        final sellersObjects =
            sellersList.map((item) => Sellers.fromJson(item)).toList();
        yield sellersObjects;
      } else {
        // Handle different types of errors
        throw Exception('Failed to load sellers: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      throw Exception('Error occurred: $e');
    }
  }

  //..................displaying menus
  Stream<List<Brands>> getBrandStream() async* {
    final response = await http.get(Uri.parse(API.displayAllBrands));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      yield data.map((brandData) => Brands.fromJson(brandData)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  //item
  Stream<List<Items>> getItemStream() async* {
    final response = await http.get(Uri.parse(API.displayfoodItems));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print(API.displayfoodItems);
      yield data.map((brandData) => Items.fromJson(brandData)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  //! get user current lat lang to fined nearby seller

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "Enable location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: const Color.fromARGB(255, 0, 0, 0),
          fontSize: 16.0);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can get the location
    return await Geolocator.getCurrentPosition();
  }
//!save lat lang in database REST API

  Future<void> sendLocationToServer(double latitude, double longitude) async {
    var uri = Uri.parse(API.saveLocationFoodUser);
    var response = await http.post(uri, body: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'user_id': userID,
    });
    print(response.body);
    if (response.statusCode == 200) {
      print('Location sent to server');
    } else {
      print('Failed to send location');
    }
  }
}
