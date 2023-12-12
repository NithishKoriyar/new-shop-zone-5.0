import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/home/home.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:http/http.dart' as http;

class PlaceOrderScreen extends StatefulWidget {
  final String? addressID;
  final int? totalAmount;
  final String? sellerUID;
  final String? cartId;
  final Carts? model;

  const PlaceOrderScreen({
    this.sellerUID,
    this.addressID,
    this.totalAmount,
    this.cartId,
    this.model,
  });

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  String orderId = DateTime.now().millisecondsSinceEpoch.toString();
  final CurrentUser currentUserController = Get.put(CurrentUser());
  bool isLoading = false;

  late String userName;
  late String userEmail;
  late String userID;

  @override
  void initState() {
    super.initState();
    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      setState(() {});
    });
  }

  void setUserInfo() {
    userName = currentUserController.user.user_name;
    userEmail = currentUserController.user.user_email;
    userID = currentUserController.user.user_id.toString();
  }

  Future<bool> saveOrderToBackend(Map<String, dynamic> orderData) async {
    var response = await http.post(
      Uri.parse(API.saveOrder),
      body: jsonEncode(orderData),
      headers: {"Content-Type": "application/json"},
    );

    var data = json.decode(response.body);

    if (response.statusCode == 200) {
      if (!data["success"]) {
        //!print("Server Error: ${data['message']}");
      }
      return data["success"];
    } else {
      //!print("HTTP Error: ${response.statusCode}");
      return false;
    }
    // ignore: dead_code
    return true;
  }

  Future<void> removeItemFromCart() async {
    final response = await http.post(
      Uri.parse(API.deleteItemFromCart),
      body: {
        'userId': userID,
        'itemId': widget.model?.itemID,
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Item removed successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Failed to remove item. Please try again.');
    }
  }

  sendNotificationToSeller(sellerUID, userOrderID) async {
    //!--------------------------------------------------------
    if (sellerUID == null) {
      //!print("sellerUID is null");
      return;
    }
    //!print("sellerUID is ${sellerUID}");
    String sellerDeviceToken = await getSellerDeviceTokenFromAPI(sellerUID);
    //!print("Retrieved seller device token-------------------------------------------------------------------------------------------: ${sellerDeviceToken}");

    if (sellerDeviceToken.isNotEmpty) {
      //print("-------------------------------------notificationFormat----------------------------------------------");

      notificationFormat(
        sellerDeviceToken,
        userOrderID,
        userName,
      );
      // print(sellerDeviceToken);
      // print(userOrderID);
      // print(userName);
    }
  }

  Future<String> getSellerDeviceTokenFromAPI(String sellerUID) async {
    final response = await http.get(
      Uri.parse('${API.getSellerDeviceTokenInUserApp}?sellerUID=$sellerUID'),
    );
    // print("================================================================");
    // print('${API.getSellerDeviceTokenInUserApp}?sellerUID=$sellerUID');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['sellerDeviceToken'] != null) {
        // print("-----------------------------------------------------------------------------------");
        // print('seller device token${data}');
        return data['sellerDeviceToken'].toString();
      }
      //!print('seller device token${data}');
    } else {
      // Handle the error accordingly
      //!print('Failed to load seller device token');
    }

    return "";
  }

  notificationFormat(sellerDeviceToken, getUserOrderID, userName) {
            //!print("-----------------------------------------notificationFormat sending------------------------------------------");
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': fcmServerToken,
    };

    Map bodyNotification = {
      'body':
          "Dear seller, New Order (# $getUserOrderID) has placed Successfully from user $userName. \nPlease Check Now",
      'title': "New Order",
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userOrderId": getUserOrderID,
    };

    Map officialNotificationFormat = {
      'notification': bodyNotification,
      'data': dataMap,
      'priority': 'high',
      'to': sellerDeviceToken,
    };

    http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }

  bool isValidOrder() {
    if (widget.addressID == null ||
        widget.model == null ||
        userID.isEmpty ||
        widget.model!.totalPrice == null ||
        widget.model!.cartId == null ||
        widget.model!.sellerUID == null ||
        widget.model!.itemCounter == null ||
        widget.model!.itemID == null) {
      return false;
    }
    return true;
  }

  Future<void> orderDetails() async {
    if (!isValidOrder()) {
      Fluttertoast.showToast(msg: "Invalid order details");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      bool isSaved = await saveOrderToBackend({
        "addressID": widget.addressID,
        "totalAmount": widget.model?.totalPrice,
        "orderBy": userID,
        "productIDs": widget.model?.cartId,
        "paymentDetails": "Cash On Delivery",
        "orderTime": DateTime.now().toString().split('.')[0], // Format: 2023-08-25 10:40:32
        "orderId": orderId,
        "isSuccess": true,
        "sellerUID": widget.model?.sellerUID,
        "status": "normal",
        "itemQuantity": widget.model?.itemCounter,
        "itemID": widget.model?.itemID,
      });

      if (isSaved) {
        await sendNotificationToSeller(
          widget.model?.sellerUID,
          orderId,
        );
        await removeItemFromCart();
        Fluttertoast.showToast(msg: "Order placed successfully.");
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Fluttertoast.showToast(msg: "Error saving order");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error in orderDetails: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/delivery.png"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : orderDetails,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Place Order Now"),
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
