import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_assistantMethods/get_current_location.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_parcel_delivering_screen.dart';
import '../maps/map_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ParcelPickingScreen extends StatefulWidget {
  String? purchaserId;
  String? sellerId;
  String? getOrderID;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;

  ParcelPickingScreen({
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
  });

  @override
  _ParcelPickingScreenState createState() => _ParcelPickingScreenState();
}

class _ParcelPickingScreenState extends State<ParcelPickingScreen> {
  double? sellerLat, sellerLng;



Future<void> getSellerData() async {
  var url = Uri.parse('${API.getLatLngOfSellerInRDR}?sellerId=${widget.sellerId}');

  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (!data.containsKey('error')) {
        // Parse the latitude and longitude values to double
        sellerLat = double.tryParse(data['latitude'] ?? '');
        sellerLng = double.tryParse(data['longitude'] ?? '');

        

        // You may want to handle the case where parsing fails and the values are null
        if (sellerLat == null || sellerLng == null) {
          print('Failed to parse latitude or longitude for sellerId: ${widget.sellerId}');
        }
      } else {
        // Handle the case where no data is found
        print('No data found for sellerId: ${widget.sellerId}');
      }
    } else {
      // Handle server error
      print('Server error: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    print('Error fetching seller data: $e');
  }
}


  @override
  void initState() {
    super.initState();

    getSellerData();
  }



void confirmParcelHasBeenPicked(String getOrderId, String sellerId, String purchaserId, String purchaserAddress, double purchaserLat, double purchaserLng) async {
  var url = Uri.parse(API.updateOrderPicking); // Replace with your actual API endpoint URL
  var response = await http.post(url, body: json.encode({
    "orderId": getOrderId,
    "status": "delivering",
    "address": purchaserAddress,
    "lat": purchaserLat,
    "lng": purchaserLng
  }));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    print(data['message']); // Handle the response as needed
  } else {
    print('Failed to update the order');
  }
}

      // Navigator.push(context, MaterialPageRoute(builder: (c)=> ParcelDeliveringScreen(
    //   purchaserId: purchaserId,
    //   purchaserAddress: purchaserAddress,
    //   purchaserLat: purchaserLat,
    //   purchaserLng: purchaserLng,
    //   sellerId: sellerId,
    //   getOrderId: getOrderId,
    // )));
  
  // confirmParcelHasBeenPicked(getOrderId, sellerId, purchaserId,
  //     purchaserAddress, purchaserLat, purchaserLng) {
  //   FirebaseFirestore.instance.collection("orders").doc(getOrderId).update({
  //     "status": "delivering",
  //     "address": completeAddress,
  //     "lat": position!.latitude,
  //     "lng": position!.longitude,
  //   });

  //   // Navigator.push(context, MaterialPageRoute(builder: (c)=> ParcelDeliveringScreen(
  //   //   purchaserId: purchaserId,
  //   //   purchaserAddress: purchaserAddress,
  //   //   purchaserLat: purchaserLat,
  //   //   purchaserLng: purchaserLng,
  //   //   sellerId: sellerId,
  //   //   getOrderId: getOrderId,
  //   // )));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "images/confirm1.png",
            width: 350,
          ),
          const SizedBox(
            height: 5,
          ),
          GestureDetector(
            onTap: () {
              //show location from rider current location towards seller location
              MapUtils.lauchMapFromSourceToDestination(position!.latitude,
                  position!.longitude, sellerLat, sellerLng);
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
                      "Show Cafe/Restaurant Location",
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
                  UserLocation uLocation = UserLocation();
                  uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenPicked(
                      widget.getOrderID.toString(),
                      widget.sellerId.toString(),
                      widget.purchaserId.toString(),
                      widget.purchaserAddress.toString(),
                      widget.purchaserLat?.toDouble() as double,
                      widget.purchaserLng?.toDouble() as double,
                      );
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
                      "Order has been Picked - Confirmed",
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
