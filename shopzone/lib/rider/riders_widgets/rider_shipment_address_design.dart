import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/riders_assistantMethods/get_current_location.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_new_orders_screen.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_parcel_picking_screen.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_model/rider_address.dart';
import 'package:http/http.dart' as http;

class ShipmentAddressDesign extends StatefulWidget {
  Orders? model;

  ShipmentAddressDesign({
    this.model,
  });

  @override
  State<ShipmentAddressDesign> createState() => _ShipmentAddressDesignState();
}

class _ShipmentAddressDesignState extends State<ShipmentAddressDesign> {
    final CurrentRider currentRiderController = Get.put(CurrentRider());
  late String riderName;
  late String riderEmail;
  String? riderID;
  late String riderImg;

  @override
  void initState() {
    super.initState();
    currentRiderController.getUserInfo().then(
      (_) {
        setRiderInfo();
        // printSellerInfo();
        setState(() {});

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

  // void printSellerInfo() {
  //   print('Seller Name: $riderName');
  //   print('Seller Email: $riderEmail');
  //   print('Seller ID: $riderID'); // Corrected variable name
  //   print('Seller image: $riderImg');
  // }

  // Function to handle parcel shipment confirmation
  void confirmedParcelShipment(
      BuildContext context, getOrderID, sellerId, purchaserId) async {
    print(API.updateOrderStatusRDR);
    var url =
        Uri.parse(API.updateOrderStatusRDR); // Change to your PHP script URL
    var response = await http.post(url, body: {
      'getOrderID': getOrderID,
      'riderUID': riderID, // Replace with actual value
      'riderName': riderName, // Replace with actual value
      'status': 'picking',
      'lat': position!.latitude.toString(), // Replace with actual value
      'lng': position!.longitude.toString(), // Replace with actual value
      'address': completeAddress, // Replace with actual value
    });

    if (response.statusCode == 200) {
      // Handle the response from the PHP script
      print('Server response: ${response.body}');
      //send rider to shipmentScreen
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelPickingScreen(
          purchaserId: purchaserId,
          purchaserAddress: widget.model?.completeAddress,
          purchaserLat: widget.model!.lat,
          purchaserLng: widget.model!.lng,
          sellerId: sellerId,
          getOrderID: getOrderID,
      )));
    } else {
      // Handle the error
      print('Server error: ${response.body}');
    }
  }

  // void confirmedParcelShipment(BuildContext context,  getOrderID,
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text('Shipping Details:',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
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
                  Text(widget.model!.phoneNumber!),
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
            widget.model!.completeAddress!,
            textAlign: TextAlign.justify,
          ),
        ),
        widget.model?.orderStatus == "ended"
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      UserLocation uLocation = UserLocation();
                      uLocation.getCurrentLocation();

                      // confirmedParcelShipment(
                      //     context, orderId!, sellerId!, orderByUser!);
                      confirmedParcelShipment(context, widget.model!.orderId,
                          widget.model!.sellerUID, widget.model!.orderBy);
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
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: const Center(
                        child: Text(
                          "Confirm - To Deliver this Parcel",
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
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
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: const Center(
                  child: Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ),
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
