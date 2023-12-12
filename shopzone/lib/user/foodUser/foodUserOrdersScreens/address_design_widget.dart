import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/global/seller_global.dart';
import 'package:shopzone/user/models/orders.dart';
import 'package:shopzone/user/foodUser/foodUserRatingScreen/rate_seller_screen.dart';
import 'package:shopzone/user/splashScreen/my_splash_screen.dart';

class AddressDesign extends StatelessWidget {
  final Orders? model;

  AddressDesign({
    this.model,
  });

  // sendNotificationToSeller() async {
  //   if (model?.sellerDeviceToken != null) {
  //     notificationFormat(
  //       model!.sellerDeviceToken!,
  //       model!.orderId!,
  //       model!.name!,  // Assuming "name" is from Orders model. Adjust if it's different.
  //     );
  //   } else {
  //     Fluttertoast.showToast(msg: "Seller token not available!");
  //   }
  // }
  sendNotificationToSeller(sellerUID, userOrderID) async {
    //!--------------------------------------------------------

    if (sellerUID == null) {
      print("sellerUID is null");
      return;
    }
    print("sellerUID is ${sellerUID}");
    String sellerDeviceToken = await getSellerDeviceTokenFromAPI(sellerUID);
    print("Retrieved seller device token-------------------------------------------------------------------------------------------: ${sellerDeviceToken}");

    if (sellerDeviceToken.isNotEmpty) {
      //print("-------------------------------------notificationFormat----------------------------------------------");

      notificationFormat(
        sellerDeviceToken,
        userOrderID,
        model!.name!
      );
      print(sellerDeviceToken);
      print(model!.orderId!,);
      print(model!.name!);
    }
  }
    Future<String> getSellerDeviceTokenFromAPI(String sellerUID) async {
    final response = await http.get(
      Uri.parse('${API.foodUserGetSellerDeviceTokenInUserApp}?sellerUID=$sellerUID'),
    );
    print("================================================================");
    print('${API.foodUserGetSellerDeviceTokenInUserApp}?sellerUID=$sellerUID');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['sellerDeviceToken'] != null) {
        print("-----------------------------------------------------------------------------------");
        print('seller device token${data}');
        return data['sellerDeviceToken'].toString();
      }
      print('seller device token${data}');
    } else {
      // Handle the error accordingly
      print('Failed to load seller device token');
    }

    return "";
  }








//!------------------------------------------
Future<void> notificationFormat(sellerDeviceToken, getUserOrderID, userName) async {
  final Map<String, String> headerNotification = {
    'Content-Type': 'application/json',
    'Authorization': fcmServerToken, // Assuming fcmServerToken is a variable holding your server key.
  };

  final Map<String, dynamic> bodyNotification = {
    'body': "Dear seller, Parcel (# $getUserOrderID) has Received Successfully by user $userName. \nPlease Check Now",
    'title': "Parcel Received by User",
  };

  final Map<String, dynamic> dataMap = {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "id": "1",
    "orderStatus": "done",
    "userOrderId": getUserOrderID,
  };

  final Map<String, dynamic> officialNotificationFormat = {
    'notification': bodyNotification,
    'data': dataMap,
    'priority': 'high',
    'to': sellerDeviceToken,
  };

  final response = await http.post(
    Uri.parse("https://fcm.googleapis.com/fcm/send"),
    headers: headerNotification,
    body: jsonEncode(officialNotificationFormat),
  );

  if (response.statusCode == 200) {
    // Notification sent successfully. You can process the response data if needed.
    print("Notification sent successfully");
  } else {
    // Handle the error. Inspect the response for details.
    print("Error sending notification. Status code: ${response.statusCode}");
    print("Response body: ${response.body}");
  }
}


  @override
  Widget build(BuildContext context) {
    //! user details from current user
    // final CurrentUser currentUserController = Get.find<CurrentUser>();
    // final String userID = currentUserController.user.user_id.toString();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Shipping Details:',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(
                children: [
                  const Text("Name", style: TextStyle(color: Colors.grey)),
                  Text(
                    model?.name ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const TableRow(
                children: [
                  SizedBox(height: 4),
                  SizedBox(height: 4),
                ],
              ),
              TableRow(
                children: [
                  const Text("Phone Number",
                      style: TextStyle(color: Colors.grey)),
                  Text(
                    model?.phoneNumber ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            model?.completeAddress ?? "",
            textAlign: TextAlign.justify,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (model?.orderStatus == "normal") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MySplashScreen()));
            } else if (model?.orderStatus == "shifted") {
             
              const String apiURL = API.foodUserUpdateNotReceivedStatus;
              final Map<String, dynamic> data = {
                'orderId': model?.orderId,
              };
              print("data ${data}");

              final response = await http.post(
                Uri.parse(apiURL),
                body: json.encode(data),
                headers: {"Content-Type": "application/json"},
              );

              if (response.statusCode == 200) {
                final Map<String, dynamic> responseBody =
                    json.decode(response.body);

                if (responseBody["status"] == "success") {
                   //! Shifted and normal status is not
              sendNotificationToSeller(model?.sellerUID, model?.orderId,);// Make sure orderByUser and orderId are set before this call

                  Fluttertoast.showToast(
                      msg:
                          responseBody["message"] ?? "Confirmed Successfully.");
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MySplashScreen()));
                } else {
                  Fluttertoast.showToast(
                      msg: responseBody["message"] ?? "Error updating data.");
                }
              } else {
                Fluttertoast.showToast(msg: "Server error. Please try again.");
              }
            } else if (model?.orderStatus == "ended") {
              // Rate the Seller feature
                      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => RateSellerScreen(
              model: model,
            ),
          ),
        );
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MySplashScreen()));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pinkAccent,
                    Colors.purpleAccent,
                  ],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              width: MediaQuery.of(context).size.width - 40,
              height: model?.orderStatus == "ended"
                  ? 60
                  : MediaQuery.of(context).size.height * .10,
              child: Center(
                child: Text(
                  getModelStatusText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getModelStatusText() {
    if (model?.orderStatus == "ended") {
      return "Do you want to Rate this Seller?";
    } else if (model?.orderStatus == "shifted") {
      return "Parcel Received, \nClick to Confirm";
    } else if (model?.orderStatus == "normal") {
      return "Go Back";
    } else {
      return "";
    }
  }
}
