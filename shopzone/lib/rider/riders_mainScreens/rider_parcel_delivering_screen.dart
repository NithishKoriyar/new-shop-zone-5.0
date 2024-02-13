import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_assistantMethods/get_current_location.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_splashScreen/riders_splash_screen.dart';
import '../maps/map_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ridersPreferences/riders_current_user.dart';

class ParcelDeliveringScreen extends StatefulWidget {
  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? sellerId;
  String? getOrderId;

  ParcelDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.sellerId,
    this.getOrderId,
  });

  @override
  _ParcelDeliveringScreenState createState() => _ParcelDeliveringScreenState();
}

class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen> {
  String orderTotalAmount = "";

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
      setState(() {});
      UserLocation uLocation = UserLocation();
      uLocation.getCurrentLocation();

      getOrderTotalAmount();
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

  confirmParcelHasBeenDelivered(getOrderId, sellerId, purchaserId,
      purchaserAddress, purchaserLat, purchaserLng) async {
    String riderNewTotalEarningAmount = ((double.parse(previousRiderEarnings)) +
            (double.parse(perParcelDeliveryAmount)))
        .toString();

    updateStatusEnded(getOrderId);
    updateEarnings(riderID, riderNewTotalEarningAmount);
    updateSellerEarnings(sellerId);
    updateOrderStatus(purchaserId, getOrderId , riderID);

    Navigator.push(
        context, MaterialPageRoute(builder: (c) => const RidersSplashScreen()));
  }

//!........................................................
  Future<void> updateStatusEnded(getOrderId) async {
    try {
      final response = await http.post(
        Uri.parse(API.updateStatusToEndedRDR),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'orderId': getOrderId,
          'status': "ended",
          'address': completeAddress,
          'lat': position!.latitude,
          'lng': position!.longitude,
          'earnings': perParcelDeliveryAmount,
        }),
      );

      if (response.statusCode == 200) {
        print("Order updated successfully: ${response.body}");
      } else {
        print("Failed to update order: ${response.body}");
      }
    } catch (e) {
      print("Exception caught: $e");
    }
  }

  Future<void> updateEarnings(riderID, riderNewTotalEarningAmount) async {
    try {
      final response = await http.post(
        Uri.parse(API.updateEarningsRDR),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'riderID': riderID,
          'earnings': riderNewTotalEarningAmount,
        }),
      );

      if (response.statusCode == 200) {
        print("Order updated successfully: ${response.body}");
      } else {
        print("Failed to update order: ${response.body}");
      }
    } catch (e) {
      print("Exception caught: $e");
    }
  }

//!------------------------------------------------------------------------------------------------

  Future<void> updateSellerEarnings(sellerId) async {
    try {
      final response = await http.post(
        Uri.parse(API.updateSellerEarningsRDR),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'sellerId': sellerId,
          'earnings': (double.parse(orderTotalAmount) +
                  (double.parse(previousEarnings)))
              .toString(),
        }),
      );

      if (response.statusCode == 200) {
        print("Order updated successfully: ${response.body}");
      } else {
        print("Failed to update order: ${response.body}");
      }
    } catch (e) {
      print("Exception caught: $e");
    }
  }
  //......................................................................

 Future<void> updateOrderStatus( purchaserId,  getOrderId,  riderID) async {
  final url = Uri.parse(API.updateOrderStatusEndingRDR); // Use your actual server URL
  final response = await http.post(url, body: {
    'purchaserId': purchaserId,
    'getOrderId': getOrderId,
    'riderUID': riderID,
  });

  if (response.statusCode == 200) {
    print('Order updated successfully');
  } else {
    print('Failed to update order');
  }
}

  void getOrderTotalAmount() async {
    final orderId = widget.getOrderId;
    final response =
        await http.get(Uri.parse('${API.getOrderDetailsRDR}?orderId=$orderId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        orderTotalAmount = data['totalAmount'].toString();
        widget.sellerId = data['sellerUID'].toString();
      });
      getSellerData();
    } else {
      print("Enable to get order total amount");
    }
  }

  void getSellerData() async {
    final response = await http
        .get(Uri.parse('${API.getSellerDataRDR}?sellerId=${widget.sellerId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        previousEarnings = data['earnings'].toString();
      });
    } else {
      print("Enable to get Seller Data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/confirm2.png",
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              //show location from rider current location towards seller location
              MapUtils.lauchMapFromSourceToDestination(
                  position!.latitude,
                  position!.longitude,
                  widget.purchaserLat,
                  widget.purchaserLng);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/restaurant.png',
                  width: 50,
                ),
                const SizedBox(
                  width: 7,
                ),
                Column(
                  children: const [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Show Delivery Drop-off Location",
                      style: TextStyle(
                        fontFamily: "Signatra",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  //rider location update
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng);
                },
                child: Container(
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
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Order has been Delivered - Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
