import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/functions/functions.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/userPreferences/current_user.dart';

class PushNotificationsSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final CurrentUser currentUserController = Get.put(CurrentUser());

  late String userName;
  late String userEmail;
  late String userID;
  late String userImg;

  PushNotificationsSystem() {
    _initializeData();
  }
  _initializeData() async {
    await currentUserController.getUserInfo();
    setUserInfo();
    printUserInfo();
  }

  void setUserInfo() {
    userName = currentUserController.user.user_name;
    userEmail = currentUserController.user.user_email;
    userID = currentUserController.user.user_id.toString();
    userImg = currentUserController.user.user_profile;
  }

  void printUserInfo() {
    print('user Name: $userName');
    print('user Email: $userEmail');
    print('user ID: $userID'); // Corrected variable name
    print('user image: $userImg');
  }

  //notifications arrived/received
  Future whenNotificationReceived(BuildContext context) async {
    //1. Terminated
    //When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open app and show notification data
        showNotificationWhenOpenApp(
          remoteMessage.data["userOrderId"],
          context,
        );
      }
    });

    //2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //directly show notification data
        showNotificationWhenOpenApp(
          remoteMessage.data["userOrderId"],
          context,
        );
      }
    });

    //3. Background
    //When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //open the app - show notification data
        showNotificationWhenOpenApp(
          remoteMessage.data["userOrderId"],
          context,
        );
      }
    });
  }

  //device recognition token
  Future generateDeviceRecognitionToken() async {
    String? registrationDeviceToken = await messaging.getToken();

// Replace the Firestore update with HTTP POST request to your API
    final response = await http.post(
      Uri.parse(API.saveFcmTokenUser),
      body: {
        'uid': userID,
        'token': registrationDeviceToken,
      },
    );
    print("---------------------------------------------saveFcmTokenUser------------------------------------------------------");
    print(API.saveFcmTokenUser);
    print(userID);
    print(registrationDeviceToken);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        print('Token updated successfully');
      } else {
        print('Error updating token: ${responseData['error']}');
      }
    } else {
      print('Failed to connect to the server');
    }

    messaging.subscribeToTopic("allSellers");
    messaging.subscribeToTopic("allUsers");
  }

  showNotificationWhenOpenApp(userOrderId, context) {
    showReusableSnackBar(
      context,
      "your Parcel (# $userOrderId) has been shifted successfully by the seller.",
    );
  }
}
