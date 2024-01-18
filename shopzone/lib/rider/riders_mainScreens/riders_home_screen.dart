import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'dart:convert';
import 'package:shopzone/foodSeller/earningsScreen/food_seller_earnings_screen.dart';
import 'package:shopzone/foodSeller/historyScreen/food_seller_history_screen.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/ridersPreferences/riders_preferences.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_new_orders_screen.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_not_yet_delivered.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_parcel_in_progress_screen.dart';
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
        decoration: index == 0 || index == 3 || index == 4
            ? const BoxDecoration(
                gradient: LinearGradient(
                colors: [
                  Colors.black,
                    Colors.black,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ))
            : const BoxDecoration(
                gradient: LinearGradient(
                colors: [
                   Colors.black,
                    Colors.black,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )),
        child: InkWell(
          onTap: () {
            if (index == 0) {
              //New Available Orders
              //Navigator.push(context,MaterialPageRoute(builder: (c) => NewOrdersScreen()));
            }
            if (index == 1) {
              //Parcels in Progress
              //Navigator.push(context,MaterialPageRoute(builder: (c) => ParcelInProgressScreen()));
            }
            if (index == 2) {
              //Not Yet Delivered
              //Navigator.push(context,MaterialPageRoute(builder: (c) => NotYetDeliveredScreen()));
            }
            if (index == 3) {
              //History
              //Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen()));
            }
            if (index == 4) {
              //Total Earnings
              //Navigator.push(context, MaterialPageRoute(builder: (c) => EarningsScreen()));
            }
            if (index == 5) {
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
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final CurrentRider currentRiderController = Get.put(CurrentRider());
  late String riderName;
  late String riderEmail;
  String? riderID;
  late String riderImg;

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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
               Colors.black,
                    Colors.black,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: Text(
          "Welcome ${riderName}" ,
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
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 1),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(2),
          children: [
            makeDashboardItem("New Available Orders", Icons.assignment, 0),
            makeDashboardItem("Parcels in Progress", Icons.airport_shuttle, 1),
            makeDashboardItem("Not Yet Delivered", Icons.location_history, 2),
            makeDashboardItem("History", Icons.done_all, 3),
            makeDashboardItem("Total Earnings", Icons.monetization_on, 4),
            makeDashboardItem("Logout", Icons.logout, 5),
          ],
        ),
      ),
    );
  }
}
