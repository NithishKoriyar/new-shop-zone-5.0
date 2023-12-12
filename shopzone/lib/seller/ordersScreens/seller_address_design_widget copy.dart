import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/global/seller_global.dart';
import 'package:shopzone/seller/models/orders.dart';
import '../splashScreen/seller_my_splash_screen.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class AddressDesign extends StatelessWidget {
  Orders? model;

  AddressDesign({
    this.model,
  });

  sendNotificationToUser(String userUID, String orderID) async {
    String userDeviceToken = await getUserDeviceTokenFromAPI(userUID);

    if (userDeviceToken.isNotEmpty) {
      notificationFormat(
        userDeviceToken,
        orderID,
        model?.name,
      );
      print("---------------------------------------------------------------------------------------------------------");
      print(userDeviceToken);
      print(orderID,);
      print(model?.name,);
    } else {
      print("user device token is empty");
    }
  }

  Future<String> getUserDeviceTokenFromAPI(String userUID) async {
    final response = await http.get(
      Uri.parse('${API.getUserDeviceTokenInSellerApp}?userUID=$userUID'),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['userDeviceToken'] != null) {
        return data['userDeviceToken'].toString();
      }
    } else {
      // Handle the error accordingly
      print('Failed to load user device token');
    }

    return "";
  }

Future<void> notificationFormat(userDeviceToken, orderID, sellerName) async {
  final Map<String, String> headerNotification = {
    'Content-Type': 'application/json',
    'Authorization': fcmServerToken, // Assuming fcmServerToken is a variable holding your server key.
  };

  final Map<String, dynamic> bodyNotification = {
    'body':
        "Dear user, your Parcel (# $orderID) has been shifted Successfully by seller $sellerName. \nPlease Check Now",
    'title': "Parcel Shifted",
  };

  final Map<String, dynamic> dataMap = {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "id": "1",
    "status": "done",
    "userOrderId": orderID,
  };

  final Map<String, dynamic> officialNotificationFormat = {
    'notification': bodyNotification,
    'data': dataMap,
    'priority': 'high',
    'to': userDeviceToken,
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
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Shipping Details:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              //name
              TableRow(
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    model!.name.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const TableRow(
                children: [
                  SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                ],
              ),

              //phone
              TableRow(
                children: [
                  const Text(
                    "Phone Number",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    model!.phoneNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            model!.completeAddress.toString(),
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (model?.orderStatus == "normal") {
              // Replace with HTTP call to update earnings and order status
              const String apiURL = API.updateEarningStatus;

              final Map<String, dynamic> data = {
                'uid': model?.sellerUID,
                'orderId': model?.orderId,
                'totalAmount': model
                    ?.totalAmount, // Make sure orderId is set before this call
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
                  //!--------------------------send notification to user - order shifted
                  sendNotificationToUser(
                      model!.orderBy.toString(), model!.orderId.toString());
                  // print("----------------------------------");
                  // print(model!.orderBy.toString());
                  // print(model!.orderId.toString());
                  // Make sure orderByUser and orderId are set before this call

                  Fluttertoast.showToast(
                      msg:
                          responseBody["message"] ?? "Confirmed Successfully.");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerSplashScreen()));
                } else {
                  Fluttertoast.showToast(
                      msg: responseBody["message"] ?? "Error updating data.");
                }
              } else {
                Fluttertoast.showToast(msg: "Server error. Please try again.");
              }
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SellerSplashScreen()));
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
              )),
              width: MediaQuery.of(context).size.width - 40,
              height: model?.orderStatus == "ended"
                  ? 60
                  : MediaQuery.of(context).size.height * .10,
              child: Center(
                child: Text(
                  model?.orderStatus == "ended"
                      ? "Go Back"
                      : model?.orderStatus == "shifted"
                          ? "Go Back"
                          : model?.orderStatus == "normal"
                              ? "Parcel Packed & \nShifted to Nearest PickUp Point. \nClick to Confirm"
                              : "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
