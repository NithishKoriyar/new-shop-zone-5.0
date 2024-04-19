import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/maps/map_utils.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/riders_assistantMethods/get_current_location.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_new_orders_screen.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_Parcels_To_Be_Picked.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/rider/riders_widgets/lat_lang.dart';

// ignore: must_be_immutable
class ShipmentAddressDesign extends StatefulWidget {
  Orders? model;

  ShipmentAddressDesign({
    this.model,
  });

  @override
  State<ShipmentAddressDesign> createState() => _ShipmentAddressDesignState();
}

// ignore: unused_element
class _ShipmentAddressDesignState extends State<ShipmentAddressDesign> {
  final CurrentRider currentRiderController = Get.put(CurrentRider());
  late String riderName;
  late String riderEmail;
  String? riderID;
  late String riderImg;
  String sellerAddress = "";
  String sellerPhone = "";
  double? sellerLat, sellerLng;

  @override
  void initState() {
    super.initState();
    currentRiderController.getUserInfo().then(
      (_) {
        setRiderInfo();
        // printSellerInfo();
        setState(() {});
        getSellerAddress();
        // restrictBlockedRidersFromUsingApp();
      },
    );
  }

  void setRiderInfo() {
    riderName = currentRiderController.rider.riders_name;
    riderEmail = currentRiderController.rider.riders_email;
    riderID = currentRiderController.rider.riders_id.toString();
    riderImg = currentRiderController.rider.riders_image;
  }

  Future<void> getSellerAddress() async {
    String? sellerUID = widget.model?.sellerUID;
    if (sellerUID != null) {
      var response = await http.post(
        Uri.parse(API.getSellerAddressRDR),
        body: {'sellerUID': sellerUID},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          sellerAddress = data['seller_address'];
          sellerPhone = data['seller_phone'];

          // Check if latitude and longitude are not null and are strings, then convert to double
          if (data["latitude"] != null && data["longitude"] != null) {
            sellerLat = double.tryParse(data["latitude"]);
            sellerLng = double.tryParse(data["longitude"]);
          }
        });
      } else {
        print('Failed to fetch seller details');
      }
    } else {
      print('Seller UID is null');
    }
  }

  //! Function to handle Accept the Parcel and set picking when parcel is ready---------------------------------------------------------------------------------
  void confirmedAcceptParcelShipment(
      BuildContext context, getOrderID, sellerId, purchaserId) async {
    var url =
        Uri.parse(API.updateOrderStatusRDR); // Change to your PHP script URL
    var response = await http.post(url, body: {
      'getOrderID': getOrderID,
      'riderUID': riderID, // Replace with actual value
      'riderName': riderName, // Replace with actual value
      'status': "picking",
      'lat': position!.latitude.toString(), // Replace with actual value
      'lng': position!.longitude.toString(), // Replace with actual value
      'address': completeAddress, // Replace with actual value
    });

    if (response.statusCode == 200) {
      print('Server response: ${response.body}');
      if (response.body.contains("Order already picked")) {
        // Display Flutter toast
        Fluttertoast.showToast(
            msg: "Order already picked",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => NewOrdersScreen()));
      }
    } else {
      // Handle the error
      print('Server error: ${response.body}');
    }
  }

  //! Function to handle pick the Parcel and set picking to delivering when parcel is ready---------------------------------------------------------------------------------
  void confirmParcelHasBeenPicked(BuildContext context, getOrderId, sellerId,
      purchaserAddress, purchaserLat, purchaserLng) async {
    var url = Uri.parse(
        API.updateOrderPicking); // Replace with your actual API endpoint URL
    var response = await http.post(url,
        body: json.encode({
          "orderId": getOrderId,
          "status": "delivering",
          "address": purchaserAddress,
          "lat": purchaserLat,
          "lng": purchaserLng
        }));

    if (response.statusCode == 200) {
                  Fluttertoast.showToast(
            msg: "Confirmed Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 34, 255, 0),
            textColor: Colors.white,
            fontSize: 16.0);

    } else {
      print('Failed to update the order');
    }
  }

  //! Function to handle pick the Parcel and set delivering to ended when parcel is delivering---------------------------------------------------------------------------------
  void confirmParcelHasBeenEnding(
      BuildContext context, getOrderId, purchaserLat, purchaserLng,riderUID) async {
    var url = Uri.parse(
        API.updateStatusToEndingRDR); // Replace with your actual API endpoint URL
    var response = await http.post(url,
        body: json.encode({
          "orderId": getOrderId,
          "status": "ending",
          "lat": purchaserLat,
          "lng": purchaserLng,
           "riderUID": riderUID
        }));

    if (response.statusCode == 200) {// Handle the response as needed
            Fluttertoast.showToast(
            msg: "Confirmed Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Color.fromARGB(255, 34, 255, 0),
            textColor: Colors.white,
            fontSize: 16.0);
    } else {
      print('Failed to update the order');
    }
  }

  // void confirmedParcelShipment(BuildContext context,  getOrderID,
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(5.0),
          child: Text('Delivery Details:',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 1),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(widget.model!.name!),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Phone Number",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(": ${widget.model!.phoneNumber!}"),
                ],
              ),
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              widget.model!.completeAddress!,
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Restaurant Address :$sellerAddress",
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text(
              "Phone :$sellerPhone",
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        Builder(
          builder: (context) {
            // Using if-else to decide which widget to display
            if (widget.model?.orderStatus == "ready") {
              //! If the status is "ready"--------------------------------------------------------------------------------------------
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    UserLocation uLocation = UserLocation();
                    uLocation.getCurrentLocation();
                    confirmedAcceptParcelShipment(
                        context,
                        widget.model!.orderId,
                        widget.model!.sellerUID,
                        widget.model!.orderBy);
                  },
                  child: const Text(
                    "Accept the Parcel",
                    style: TextStyle(
                      color: Colors.white, // Set text color here
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Colors.green), // Set background color here
                  ),
                ),
              );
            } else if (widget.model?.orderStatus == "picking") {
              //! If the status is "picking"--------------------------------------------------------------------------------------------
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centers the buttons horizontally
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        LatLang latLang = LatLang();
                        await latLang
                            .requestPermission(); // Ensure permissions are granted
                        Position currentPosition = await latLang
                            .getPosition(); // Fetch current position
                        // Use currentPosition to get latitude and longitude
                        MapUtils.lauchMapFromSourceToDestination(
                            "${currentPosition.latitude}",
                            "${currentPosition.longitude}",
                            sellerLat, // Ensure this is defined somewhere in your widget
                            sellerLng); // Ensure this is defined somewhere in your widget
                      },
                      child: Text('Open Restaurant Location'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(
                                255, 0, 255, 8)), // Set background color here
                      ),
                    ),

                    const SizedBox(
                        width:
                            20), // Provides some space between the two buttons
                    ElevatedButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // Return the actual dialog widget
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Do you want to pick the parcel?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // If user cancels, just close the dialog
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    print(widget.model?.lat);
                                    // Pop the dialog first
                                    Navigator.of(context).pop();
                                    // Then proceed with the original button actions
                                    UserLocation uLocation = UserLocation();
                                    uLocation.getCurrentLocation();
                                    confirmParcelHasBeenPicked(
                                      context,
                                      widget.model!.orderId,
                                      widget.model!.sellerUID,
                                      widget.model!.completeAddress,
                                      widget.model!.lat,
                                      widget.model!.lng,
                                    );

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Pick the Parcel',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 255, 0, 0),
                        ), // Red background color
                      ),
                    ),
                  ],
                ),
              );
            } else if (widget.model?.orderStatus == "delivering") {
              //! If the status is "delivering"--------------------------------------------------------------------------------------------
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Centers the buttons horizontally
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        LatLang latLang = LatLang();
                        await latLang
                            .requestPermission(); // Ensure permissions are granted
                        Position currentPosition = await latLang
                            .getPosition(); // Fetch current position
                        // Use currentPosition to get latitude and longitude
                        MapUtils.lauchMapFromSourceToDestinationName(
                            "${currentPosition.latitude}",
                            "${currentPosition.longitude}",
                           widget.model!.completeAddress!);// Ensure this is defined somewhere in your widget
                          
 // Ensure this is defined somewhere in your widget
                      },
                      child: Text('Open Delivery Location'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(
                                255, 0, 255, 8)), // Set background color here
                      ),
                    ),

                    const SizedBox(
                        width:
                            20), // Provides some space between the two buttons
                    ElevatedButton(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // Return the actual dialog widget
                            return AlertDialog(
                              title: Text('Confirmation'),
                              content: Text('Parcel Deliverd?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // If user cancels, just close the dialog
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    print(widget.model?.lat);
                                    // Pop the dialog first
                                    Navigator.of(context).pop();
                                    // Then proceed with the original button actions
                                    UserLocation uLocation = UserLocation();
                                    uLocation.getCurrentLocation();
                                    confirmParcelHasBeenEnding(
                                      context,
                                      widget.model!.orderId,
                                      widget.model!.lat,
                                      widget.model!.lng,
                                      widget.model!.riderUID
                                    );

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Confirm Deliver',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 255, 0, 0),
                        ), // Red background color
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // For any other status, show the confirmation button.
              return Container(); // If the order status is "ended", show an empty container.
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                print(widget.model?.riderUID);
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
//hi