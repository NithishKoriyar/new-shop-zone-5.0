import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/foodSeller/brandsScreens/food_seller_brands_ui_design_widget.dart';
import 'package:shopzone/foodSeller/brandsScreens/food_seller_upload_brands_screen.dart';
import 'package:shopzone/foodSeller/models/food_seller_brands.dart';
import 'package:shopzone/foodSeller/push_notifications/food_seller_push_notifications_system.dart';
import 'package:shopzone/foodSeller/widgets/food_seller_text_delegate_header_widget.dart';
import 'package:shopzone/noConnectionPage.dart';
import 'package:shopzone/notification_service.dart';
import '../../api_key.dart';
import '../foodSellerPreferences/food_current_seller.dart';
import '../widgets/food_seller_my_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getSellerEarningsFromDatabase() {
    // FirebaseFirestore.instance
    //     .collection("sellers")
    //     .doc(sharedPreferences!.getString("uid"))
    //     .get()
    //     .then((dataSnapShot)
    // {
    //   previousEarning = dataSnapShot.data()!["earnings"].toString();
    // }).whenComplete(()
    // {
    //   restrictBlockedSellersFromUsingSellersApp();
    // });
  }

  restrictBlockedSellersFromUsingSellersApp() async {
    // await FirebaseFirestore.instance
    //     .collection("sellers")
    //     .doc(sharedPreferences!.getString("uid"))
    //     .get().then((snapshot)
    // {
    //   if(snapshot.data()!["status"] != "approved")
    //   {
    //     showReusableSnackBar(context, "you are blocked by admin.");
    //     showReusableSnackBar(context, "contact admin: admin2@jan-G-shopy.com");

    //     FirebaseAuth.instance.signOut();
    //     Navigator.push(context, MaterialPageRoute(builder: (c)=> SellerSplashScreen()));
    //   }
    // });
  }

  //!seller information--------------------------------------
  final CurrentFoodSeller currentSellerController =
      Get.put(CurrentFoodSeller());
  String latitude = '';
  String longitude = '';
  late String sellerName;
  late String sellerEmail;
  String? sellerID;
  late String sellerImg;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
      fetchLocation(sellerID!);
      printSellerInfo();

      setState(() {});
      notificationServices.requestNotificationPermissions();
      PushNotificationsSystem pushNotificationsSystem =
          PushNotificationsSystem();
      pushNotificationsSystem.whenNotificationReceived(context);
      pushNotificationsSystem.generateDeviceRecognitionToken();

      getSellerEarningsFromDatabase();
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
    sellerImg = currentSellerController.seller.seller_profile;
  }

  void printSellerInfo() {
    // print('Seller Name: $sellerName');
    // print('Seller Email: $sellerEmail');
    // print('Seller ID: $sellerID'); // Corrected variable name
    // print('Seller image: $sellerImg');
  }
  //!seller information--------------------------------------

  @override
  Widget build(BuildContext context) {
    // Register CurrentSeller instance with GetX
    Get.put(CurrentFoodSeller());
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Shop Zone Foods",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => UploadBrandsScreen()));
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(title: "Menu's"),
          ),

          //1. write query
          //2  model
          //3. ui design widget
          if (sellerID != null)
            StreamBuilder(
              stream: fetchBrandsStream(sellerID!),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                     child: Center(child: NoConnectionPage()),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No brands exists')),
                  );
                } else {
                  List<dynamic> data = snapshot.data!;
                  return SliverStaggeredGrid.countBuilder(
                    crossAxisCount: 1,
                    staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) {
                      Brands brandsModel = Brands.fromJson(data[index]);
                      return BrandsUiDesignWidget(
                        model: brandsModel,
                        context: context,
                      );
                    },
                    itemCount: data.length,
                  );
                }
              },
            )
        ],
      ),
    );
  }

//   final String apiUrl = '${API.foodSellerCurrentSellerBrandView}?uid=$sellerID';
//http://192.168.0.113/amazon%20clone%20in%20backend%20php/shop_zone/shop_zone_api/seller/Brands.php
  Stream<List<dynamic>> fetchBrandsStream(String sellerID) async* {
    final response = await http.get(Uri.parse(
        "${API.foodSellerCurrentSellerBrandView}?sellerID=$sellerID"));

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);

      if (decodedResponse is List<dynamic>) {
        yield decodedResponse;
        // print("++++++++++++++++++++++++++");
        print(decodedResponse);
      } else {
        //throw Exception('Expected a list but got a different type');
        const Text('No brands exists');
      }
    } else {
      throw Exception('Failed to load brands');
    }
  }

  Future<void> fetchLocation(String sellerID) async {
    var url = Uri.parse('${API.fetchSellerLocation}?sellerID=$sellerID');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Use null-aware operators to handle null values
      String latitude = data['latitude']?.toString() ?? '';
      String longitude = data['longitude']?.toString() ?? '';

      if (latitude.isNotEmpty && longitude.isNotEmpty) {
        // Use the data as needed
        print('Latitude: $latitude, Longitude: $longitude');
        // Additional logic based on the fetched data
      } else {
        print("Latitude or longitude is empty");
        // Handle the case where latitude or longitude is empty
        _showUpdateLocationDialog();
      }
    } else {
      print("Failed to fetch location: ${response.statusCode}");
    }
  }
  //updateLocation

  Future<void> updateLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get the address from the coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      String fullAddress =
          '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';

      // Update the backend with the location and address
      var url = Uri.parse(API.updateSellerLocation);
      var response = await http.post(url, body: {
        'user_id': sellerID.toString(),
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'address': fullAddress, // Send the full address
      });

      // Handle the response
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          Fluttertoast.showToast(
              msg: "Location and address updated successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "Failed to update location and address",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error: ${response.statusCode}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Failed to get location: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _showUpdateLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Location'),
          content:
              Text('Your location is not set. Would you like to update it?'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Update Location'),
              onPressed: () {
                Navigator.of(context).pop();
                updateLocation();
              },
            ),
          ],
        );
      },
    );
  }
}
