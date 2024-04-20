// import 'dart:convert';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shopzone/api_key.dart';
// import 'package:shopzone/rider/maps/map_utils.dart';
// import 'package:shopzone/rider/riders_widgets/lat_lang.dart';
// import 'package:shopzone/seller/global/seller_global.dart';
// import 'package:shopzone/user/models/orders.dart';
// import 'package:shopzone/user/foodUser/foodUserRatingScreen/rate_seller_screen.dart';
// import 'package:shopzone/user/splashScreen/my_splash_screen.dart';

// class AddressDesign extends StatefulWidget {
//   final Orders? model;

//   AddressDesign({
//     this.model,
//   });

//   @override
//   State<AddressDesign> createState() => _AddressDesignState();
// }

// class _AddressDesignState extends State<AddressDesign> {
//   String locationInfo = '';

//   // sendNotificationToSeller() async {
//   sendNotificationToSeller(sellerUID, userOrderID) async {
//     //!--------------------------------------------------------

//     if (sellerUID == null) {
//       print("sellerUID is null");
//       return;
//     }
//     print("sellerUID is ${sellerUID}");
//     String sellerDeviceToken = await getSellerDeviceTokenFromAPI(sellerUID);
//     print(
//         "Retrieved seller device token-------------------------------------------------------------------------------------------: ${sellerDeviceToken}");

//     if (sellerDeviceToken.isNotEmpty) {
//       //print("-------------------------------------notificationFormat----------------------------------------------");

//       notificationFormat(sellerDeviceToken, userOrderID, widget.model!.name!);
//       print(sellerDeviceToken);
//       print(
//         widget.model!.orderId!,
//       );
//       print(widget.model!.name!);
//     }
//   }

//   Future<String> getSellerDeviceTokenFromAPI(String sellerUID) async {
//     final response = await http.get(
//       Uri.parse(
//           '${API.foodUserGetSellerDeviceTokenInUserApp}?sellerUID=$sellerUID'),
//     );

//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       if (data['sellerDeviceToken'] != null) {
//         return data['sellerDeviceToken'].toString();
//       }
//     } else {
//       // Handle the error accordingly
//     }

//     return "";
//   }

// //!------------------------------------------
//   Future<void> notificationFormat(
//       sellerDeviceToken, getUserOrderID, userName) async {
//     final Map<String, String> headerNotification = {
//       'Content-Type': 'application/json',
//       'Authorization':
//           fcmServerToken, // Assuming fcmServerToken is a variable holding your server key.
//     };

//     final Map<String, dynamic> bodyNotification = {
//       'body':
//           "Dear seller, Parcel (# $getUserOrderID) has Received Successfully by user $userName. \nPlease Check Now",
//       'title': "Parcel Received by User",
//     };

//     final Map<String, dynamic> dataMap = {
//       "click_action": "FLUTTER_NOTIFICATION_CLICK",
//       "id": "1",
//       "orderStatus": "done",
//       "userOrderId": getUserOrderID,
//     };

//     final Map<String, dynamic> officialNotificationFormat = {
//       'notification': bodyNotification,
//       'data': dataMap,
//       'priority': 'high',
//       'to': sellerDeviceToken,
//     };

//     final response = await http.post(
//       Uri.parse("https://fcm.googleapis.com/fcm/send"),
//       headers: headerNotification,
//       body: jsonEncode(officialNotificationFormat),
//     );

//     if (response.statusCode == 200) {
//       // Notification sent successfully. You can process the response data if needed.
//       print("Notification sent successfully");
//     } else {
//       // Handle the error. Inspect the response for details.
//       print("Error sending notification. Status code: ${response.statusCode}");
//       print("Response body: ${response.body}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     //! user details from current user
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Call the getLocation function on page load
//       if (widget.model?.lat != null && widget.model?.lng != null) {
//         getLocation(widget.model?.lat, widget.model?.lng);
//       } else {
//         print("Latitude or longitude data is missing.");
//       }
//     });
//     // final CurrentUser currentUserController = Get.find<CurrentUser>();
//     // final String userID = currentUserController.user.user_id.toString();

//     return Column(
//       children: [
//         const Padding(
//           padding: EdgeInsets.all(10.0),
//           child: Text(
//             'Shipping Details:',
//             style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
//           ),
//         ),
//         const SizedBox(height: 6.0),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
//           width: MediaQuery.of(context).size.width,
//           child: Table(
//             children: [
//               TableRow(
//                 children: [
//                   const Text("Name", style: TextStyle(color: Colors.grey)),
//                   Text(
//                     widget.model?.name ?? "",
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const TableRow(
//                 children: [
//                   SizedBox(height: 4),
//                   SizedBox(height: 4),
//                 ],
//               ),
//               TableRow(
//                 children: [
//                   const Text("Phone Number",
//                       style: TextStyle(color: Colors.grey)),
//                   Text(
//                     widget.model?.phoneNumber ?? "",
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Text(
//             widget.model?.completeAddress ?? "",
//             textAlign: TextAlign.justify,
//             style: const TextStyle(color: Colors.grey),
//           ),
//         ),
//         GestureDetector(
//           onTap: () async {
//             if (widget.model?.orderStatus == "ending") {
//               const String apiURL = API.foodUserUpdateNotReceivedStatus;
//               final Map<String, dynamic> data = {
//                 'orderId': widget.model?.orderId,
//               };

//               final response = await http.post(
//                 Uri.parse(apiURL),
//                 body: json.encode(data),
//                 headers: {"Content-Type": "application/json"},
//               );

//               if (response.statusCode == 200) {
//                 final Map<String, dynamic> responseBody =
//                     json.decode(response.body);

//                 if (responseBody["status"] == "success") {
//                   //! Shifted and normal status is not
//                   sendNotificationToSeller(
//                     widget.model?.sellerUID,
//                     widget.model?.orderId,
//                   ); // Make sure orderByUser and orderId are set before this call

//                   Fluttertoast.showToast(
//                       msg:
//                           responseBody["message"] ?? "Confirmed Successfully.");
//                   // ignore: use_build_context_synchronously
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const MySplashScreen()));
//                 } else {
//                   Fluttertoast.showToast(
//                       msg: responseBody["message"] ?? "Error updating data.");
//                 }
//               } else {
//                 Fluttertoast.showToast(msg: "Server error. Please try again.");
//               }
//             } else if (widget.model?.orderStatus == "ended") {
//               // Rate the Seller feature
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (c) => RateSellerScreen(
//                     model: widget.model,
//                   ),
//                 ),
//               );
//             } else {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const MySplashScreen()));
//             }
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Container(
//               color: Colors.green,
//               width: MediaQuery.of(context).size.width - 40,
//               height: widget.model?.orderStatus == "ended"
//                   ? 60
//                   : MediaQuery.of(context).size.height * .10,
//               child: Center(
//                 child: Text(
//                   getModelStatusText(),
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white, fontSize: 15),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             LatLang latLang = LatLang();
//             await latLang.requestPermission(); // Ensure permissions are granted
//             Position currentPosition =
//                 await latLang.getPosition(); // Fetch current position
//             // Use currentPosition to get latitude and longitude
//             await getLocation(
//                 currentPosition.latitude,
//                 currentPosition
//                     .longitude); // Call getLocation function to update locationInfo
//             MapUtils.lauchMapFromSourceToDestination(
//                 "${currentPosition.latitude}",
//                 "${currentPosition.longitude}",
//                 widget.model?.lat, // Ensure this is defined somewhere in your widget
//                 widget.model?.lng); // Ensure this is defined somewhere in your widget
//           },
//           child: Text(
//               locationInfo.isEmpty ? 'Fetching Location...' : locationInfo),
//         ),
//         ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('Go Back'))
//       ],
//     );
//   }

//   Future<void> getLocation(double? latitude, double? longitude) async {
//     // Check if either latitude or longitude is null
//     if (latitude == null || longitude == null) {
//       print('Invalid coordinates: Latitude and longitude must not be null.');
//       return;
//     }

//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(latitude, longitude);
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         locationInfo =
//             '${place.locality}, ${place.postalCode}, ${place.country}';
//         print('Location: $locationInfo');
//       } else {
//         print('No location found for the provided coordinates.');
//       }
//     } catch (e) {
//       print('Failed to get location: $e');
//     }

//     // You can now use the locationInfo variable as needed
//     // For example, you can return it or pass it to another function
//     // return locationInfo;
//   }

//   String getModelStatusText() {
//     if (widget.model?.orderStatus == "ended") {
//       return "Do you want to Rate this Seller?";
//     } else if (widget.model?.orderStatus == "ending") {
//       return "Parcel Received, \nClick to Confirm";
//     } else {
//       return "Parcel In Progress please wait";
//     }
//   }
// }

import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/maps/map_utils.dart';
import 'package:shopzone/rider/riders_widgets/lat_lang.dart';
import 'package:shopzone/seller/global/seller_global.dart';
import 'package:shopzone/user/models/orders.dart';
import 'package:shopzone/user/foodUser/foodUserRatingScreen/rate_seller_screen.dart';
import 'package:shopzone/user/splashScreen/my_splash_screen.dart';

class AddressDesign extends StatefulWidget {
  final Orders? model;

  AddressDesign({
    this.model,
  });

  @override
  State<AddressDesign> createState() => _AddressDesignState();
}

class _AddressDesignState extends State<AddressDesign> {
  String locationInfo = '';

  @override
  void initState() {
    super.initState();
    // Call the getLocation function when the widget is initialized
    getLocation(widget.model?.lat, widget.model?.lng);
  }

  // sendNotificationToSeller() async {
  sendNotificationToSeller(sellerUID, userOrderID) async {
    //!--------------------------------------------------------

    if (sellerUID == null) {
      print("sellerUID is null");
      return;
    }
    print("sellerUID is ${sellerUID}");
    String sellerDeviceToken = await getSellerDeviceTokenFromAPI(sellerUID);
    print(
        "Retrieved seller device token-------------------------------------------------------------------------------------------: ${sellerDeviceToken}");

    if (sellerDeviceToken.isNotEmpty) {
      //print("-------------------------------------notificationFormat----------------------------------------------");

      notificationFormat(sellerDeviceToken, userOrderID, widget.model!.name!);
      print(sellerDeviceToken);
      print(
        widget.model!.orderId!,
      );
      print(widget.model!.name!);
    }
  }

  Future<String> getSellerDeviceTokenFromAPI(String sellerUID) async {
    final response = await http.get(
      Uri.parse(
          '${API.foodUserGetSellerDeviceTokenInUserApp}?sellerUID=$sellerUID'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['sellerDeviceToken'] != null) {
        return data['sellerDeviceToken'].toString();
      }
    } else {
      // Handle the error accordingly
    }

    return "";
  }

//!------------------------------------------
  Future<void> notificationFormat(
      sellerDeviceToken, getUserOrderID, userName) async {
    final Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization':
          fcmServerToken, // Assuming fcmServerToken is a variable holding your server key.
    };

    final Map<String, dynamic> bodyNotification = {
      'body':
          "Dear seller, Parcel (# $getUserOrderID) has Received Successfully by user $userName. \nPlease Check Now",
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
                    widget.model?.name ?? "",
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
                    widget.model?.phoneNumber ?? "",
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
            widget.model?.completeAddress ?? "",
            textAlign: TextAlign.justify,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: () async {
            if (widget.model?.orderStatus == "ending") {
              const String apiURL = API.foodUserUpdateNotReceivedStatus;
              final Map<String, dynamic> data = {
                'orderId': widget.model?.orderId,
              };

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
                  sendNotificationToSeller(
                    widget.model?.sellerUID,
                    widget.model?.orderId,
                  ); // Make sure orderByUser and orderId are set before this call

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
            } else if (widget.model?.orderStatus == "ended") {
              // Rate the Seller feature
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => RateSellerScreen(
                    model: widget.model,
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
              color: Colors.green,
              width: MediaQuery.of(context).size.width - 40,
              height: widget.model?.orderStatus == "ended"
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
Visibility(
  visible: widget.model?.lat != 0.0 && widget.model?.lng != 0.0,
  child: ElevatedButton(
    onPressed: () async {
      LatLang latLang = LatLang();
      await latLang.requestPermission(); // Ensure permissions are granted
      Position currentPosition =
          await latLang.getPosition(); // Fetch current position
      // Use currentPosition to get latitude and longitude
      await getLocation(
        currentPosition.latitude,
        currentPosition.longitude,
      ); // Call getLocation function to update locationInfo
      MapUtils.lauchMapFromSourceToDestination(
        "${currentPosition.latitude}",
        "${currentPosition.longitude}",
        widget.model
            ?.lat, // Ensure this is defined somewhere in your widget
        widget.model
            ?.lng, // Ensure this is defined somewhere in your widget
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red, // Background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Remove border radius
      ),
    ),
    child: Center(
      child: Text(
        locationInfo.isEmpty
            ? 'Fetching Location...'
            : "$locationInfo\nClick here to Track",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
),

        ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'))
      ],
    );
  }

  Future<void> getLocation(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) {
      print('Invalid coordinates: Latitude and longitude must not be null.');
      return;
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          locationInfo =
              '${place.locality}, ${place.postalCode}, ${place.country}';
        });
        print('Location: $locationInfo');
      } else {
        print('No location found for the provided coordinates.');
      }
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  String getModelStatusText() {
    if (widget.model?.orderStatus == "ended") {
      return "Do you want to Rate this Seller?";
    } else if (widget.model?.orderStatus == "ending") {
      return "Parcel Received, \nClick to Confirm";
    } else {
      return "Parcel In Progress please wait";
    }
  }
}
