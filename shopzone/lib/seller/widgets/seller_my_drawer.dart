
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/seller/brandsScreens/seller_home_screen.dart';
import 'package:shopzone/seller/earningsScreen/seller_earnings_screen.dart';
import 'package:shopzone/seller/historyScreen/seller_history_screen.dart';
import 'package:shopzone/seller/ordersScreens/seller_orders_screen.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import 'package:shopzone/seller/sellerPreferences/seller_preferences.dart';
import 'package:shopzone/seller/shiftedParcelsScreen/seller_shifted_parcels_screen.dart';
import 'package:shopzone/user/splashScreen/my_splash_screen.dart';
import '../../api_key.dart';
import '../splashScreen/seller_my_splash_screen.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;
  late String sellerImg;

  bool dataLoaded = false;  // added this flag

  @override
  void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
      printSellerInfo();
      setState(() {});  // This will trigger a rebuild once data is loaded.
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
    sellerImg = currentSellerController.seller.seller_profile;

    dataLoaded = true;  // set the flag to true here
  }

  void printSellerInfo() {
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller ID: $sellerID');
    print('Seller image: $sellerImg');
  }

  @override
  Widget build(BuildContext context) {
    if (!dataLoaded) {
      // Return a loading widget or an empty drawer until data is loaded
      return Drawer(child: Center(child: CircularProgressIndicator()));
    }

    return Drawer(
      backgroundColor: Colors.black54,
 child: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 26, bottom: 12),
            child: Column(
              children: [
                // User profile image
                SizedBox(
                  height: 130,
                  width: 130,
                  child: CircleAvatar(
                   backgroundImage: NetworkImage(API.sellerImage + sellerImg),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // User name
                Text(
                  sellerName,
                 style: const TextStyle(
                   color: Colors.white,
                  fontSize: 20,
                   fontWeight: FontWeight.bold,
                  ),
                 ),

                const SizedBox(height: 12,),

              ],
            ),
          ),

          //body
          Container(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              children: [

                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

                //home
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white,),
                  title: const Text(
                    "Home",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

                //earnings
                ListTile(
                  leading: const Icon(Icons.currency_rupee, color: Colors.white,),
                  title: const Text(
                    "Earnings",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> EarningsScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

                //my orders
                ListTile(
                  leading: const Icon(Icons.reorder, color: Colors.white,),
                  title: const Text(
                    "New Orders",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> OrdersScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

                //Shifted Parcels
                ListTile(
                  leading: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white,),
                  title: const Text(
                    "Shifted Parcels",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> ShiftedParcelsScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

                //history
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.white,),
                  title: const Text(
                    "History",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> HistoryScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

                //logout
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.white,),
                  title: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                     RememberSellerPrefs.removeSellerInfo();
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> const SellerSplashScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.supervisor_account_sharp, color: Colors.white,),
                  title: const Text(
                    "Be a User",
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.white,
                  thickness: 2,
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
