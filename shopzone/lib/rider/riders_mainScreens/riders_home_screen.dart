import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'dart:convert';
import 'package:shopzone/foodSeller/historyScreen/food_seller_history_screen.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/ridersPreferences/riders_preferences.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_Delivery_Confirmation.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_new_orders_screen.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_Picked_Parcels.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_Parcels_To_Be_Picked.dart';
import '../riders_authentication/riders_auth_screen.dart';

class RidersHomeScreen extends StatefulWidget {
  const RidersHomeScreen({Key? key}) : super(key: key);

  @override
  _RidersHomeScreenState createState() => _RidersHomeScreenState();
}

class _RidersHomeScreenState extends State<RidersHomeScreen> {
  Card makeDashboardItem(String title, IconData iconData, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Container(
        

        child: InkWell(
          onTap: () {
            if (index == 0) {
              //New Available Orders
      
              Navigator.push(context,MaterialPageRoute(builder: (c) => NewOrdersScreen()));
            }
            if (index == 1) {
              //Parcels in Progress
              Navigator.push(context,MaterialPageRoute(builder: (c) => ParcelToBePickedScreen()));
            }
            if (index == 2) {
              //Not Yet Delivered
              Navigator.push(context,MaterialPageRoute(builder: (c) => PickedParcels()));
            }
             if (index == 3) {
              //Not Yet Delivered
              Navigator.push(context,MaterialPageRoute(builder: (c) => DeliveryConfirmation()));
            }
            if (index == 4) {
              //History
              Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen()));
            }
            if (index == 5) {
              //Total Earnings
              // Navigator.push(context, MaterialPageRoute(builder: (c) => EarningsScreen()));
            }
            if (index == 6) {
              //Logout
              RememberRiderPrefs.removeUserInfo();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const AuthScreen()));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: [
              const SizedBox(height: 50.0),
              Center(
                child: Icon(
                  iconData,
                  size: 40,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 47, 47, 47),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }



  // restrictBlockedRidersFromUsingApp() async
  // {
  //   await FirebaseFirestore.instance.collection("riders")
  //       .doc(firebaseAuth.currentUser!.uid)
  //       .get().then((snapshot)
  //   {
  //     if(snapshot.data()!["status"] != "approved")
  //     {
  //       Fluttertoast.showToast(msg: "you have been Blocked");

  //       firebaseAuth.signOut();
  //       Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
  //     }
  //     else
  //     {
  //       UserLocation uLocation = UserLocation();
  //       uLocation.getCurrentLocation();
  //       getPerParcelDeliveryAmount();
  //       getRiderPreviousEarnings();
  //     }
  //   });
  // }

  final CurrentRider currentRiderController = Get.put(CurrentRider());
  late String riderName;
  late String riderEmail;
  String? riderID;
  late String riderImg;
  
  @override
  void initState() {
    super.initState();
    currentRiderController.getUserInfo().then((_) {
      setRiderInfo();
      printSellerInfo();
      setState(() {});

      // restrictBlockedRidersFromUsingApp();
    });
  }

  void setRiderInfo() {
    riderName = currentRiderController.rider.riders_name;
    riderEmail = currentRiderController.rider.riders_email;
    riderID = currentRiderController.rider.riders_id.toString();
    riderImg = currentRiderController.rider.riders_image;
  }

  void printSellerInfo() {
    print('Seller Name: $riderName');
    print('Seller Email: $riderEmail');
    print('Seller ID: $riderID'); // Corrected variable name
    print('Seller image: $riderImg');
  }

  void getRiderPreviousEarnings() async {
    String apiUrl = "${API.riderEarnings}?uid=$riderID";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        previousRiderEarnings = data['earnings'].toString();
      } else {
        // Handle server error
      }
    } catch (e) {
      // Handle network error
    }
  }

  void getPerParcelDeliveryAmount() async {
    String apiUrl = API.deliveryAmount;

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        perParcelDeliveryAmount = data['amount'].toString();
      } else {
        // Handle server error
      }
    } catch (e) {
      // Handle network error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: Text(
          "Welcome",
          style: const TextStyle(
            fontSize: 25.0,
            color: Colors.black,
            fontFamily: "Signatra",
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(1),
          children: [
            makeDashboardItem("New Orders", Icons.assignment, 0),
            makeDashboardItem("Parcels To Be Picked", Icons.post_add_sharp, 1),
            makeDashboardItem("Picked Parcels", Icons.delivery_dining_sharp, 2),
            makeDashboardItem("Delivery ", Icons.delivery_dining_sharp, 3),
            makeDashboardItem("History", Icons.done_all, 4),
            makeDashboardItem("Total Earnings", Icons.monetization_on, 5),
            makeDashboardItem("Logout", Icons.logout, 6),
          ],
        ),
      ),
    );
  }
}
