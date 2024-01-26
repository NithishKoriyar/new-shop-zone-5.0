import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/notification_service.dart';
import 'package:shopzone/seller/brandsScreens/seller_brands_ui_design_widget.dart';
import 'package:shopzone/seller/brandsScreens/seller_upload_brands_screen.dart';
import 'package:shopzone/seller/models/seller_brands.dart';
import 'package:shopzone/seller/push_notifications/seller_push_notifications_system.dart';
import 'package:shopzone/seller/widgets/seller_text_delegate_header_widget.dart';
import '../../api_key.dart';
import '../sellerPreferences/current_seller.dart';
import '../widgets/seller_my_drawer.dart';

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
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

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
      printSellerInfo();

      setState(() {});
          notificationServices.requestNotificationPermissions();
      PushNotificationsSystem pushNotificationsSystem = PushNotificationsSystem();
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
    Get.put(CurrentSeller());
    return Scaffold(
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
            delegate: TextDelegateHeaderWidget(title: "My Brands"),
          ),

          //1. write query
          //2  model
          //3. ui design widget
          if (sellerID != null)
            StreamBuilder(
              stream: fetchBrandsStream(sellerID!),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
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

//   final String apiUrl = '${API.currentSellerBrandView}?uid=$sellerID';
//http://192.168.0.113/amazon%20clone%20in%20backend%20php/shop_zone/shop_zone_api/seller/Brands.php
  Stream<List<dynamic>> fetchBrandsStream(String sellerID) async* {
    final response = await http
        .get(Uri.parse("${API.currentSellerBrandView}?sellerID=$sellerID"));
    print("${API.currentSellerBrandView}?sellerID=$sellerID");

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
}
