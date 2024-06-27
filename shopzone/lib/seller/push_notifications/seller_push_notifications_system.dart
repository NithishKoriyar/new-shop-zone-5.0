import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';

class PushNotificationsSystem {
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;
  late String sellerImg;
  //FirebaseMessaging messaging = FirebaseMessaging.instance;

  PushNotificationsSystem() {
    _initializeData();
  }

  _initializeData() async {
    await currentSellerController.getSellerInfo();
    setSellerInfo();
    printSellerInfo();
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
    sellerImg = currentSellerController.seller.seller_profile;
  }

  void printSellerInfo() {
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller ID: $sellerID');
    print('Seller image: $sellerImg');
  }

  //notifications arrived/received
  Future whenNotificationReceived(BuildContext context) async {
    //1. Terminated
    //When the app is completely closed and opened directly from the push notification
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? remoteMessage) {
    //   if (remoteMessage != null) {
    //     //open app and show notification data
    //     showNotificationWhenOpenApp(
    //       remoteMessage.data["userOrderId"],
    //       context,
    //     );
    //   }
    // });

    // //2. Foreground
    // //When the app is open and it receives a push notification
    // FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
    //   if (remoteMessage != null) {
    //     //directly show notification data
    //     showNotificationWhenOpenApp(
    //       remoteMessage.data["userOrderId"],
    //       context,
    //     );
    //   }
    // });

    // //3. Background
    // //When the app is in the background and opened directly from the push notification.
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
    //   if (remoteMessage != null) {
    //     //open the app - show notification data
    //     showNotificationWhenOpenApp(
    //       remoteMessage.data["userOrderId"],
    //       context,
    //     );
    //   }
    // });
  }

  //device recognition token
  Future generateDeviceRecognitionToken() async {
    //String? registrationDeviceToken = await messaging.getToken();

// Replace the Firestore update with HTTP POST request to your API
    final response = await http.post(
      Uri.parse(API.saveFcmToken),
      body: {
        'uid': sellerID,
        'token': "registrationDeviceToken",
      },
    );
    // print(API.saveFcmToken);
    // print(sellerID);
    // print(registrationDeviceToken);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        //print('Token updated successfully');
      } else {
        //print('Error updating token: ${responseData['error']}');
      }
    } else {
      //print('Failed to connect to the server');
    }

    // messaging.subscribeToTopic("allSellers");
    // messaging.subscribeToTopic("allUsers");
  }

  showNotificationWhenOpenApp(orderID, context) async {
    final response = await http.get(
      Uri.parse('${API.getOrderStatus}?orderID=$orderID'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['orderStatus'] == "ended") {
        showReusableSnackBar(context,
            "Order ID # $orderID \n\n has delivered & received by the user.");
      } else {
        showReusableSnackBar(context,
            "you have new Order. \nOrder ID # $orderID \n\n Please Check now.");
      }
    } else {
      // Handle the error accordingly

      print('Failed to load order status');
    }
  }
}
