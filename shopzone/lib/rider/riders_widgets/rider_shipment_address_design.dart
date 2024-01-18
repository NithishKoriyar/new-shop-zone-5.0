import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/riders_assistantMethods/get_current_location.dart';
import 'package:shopzone/rider/riders_global/global.dart';
import 'package:shopzone/rider/riders_model/rider_address.dart';
import 'package:shopzone/rider/riders_splashScreen/riders_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentAddressDesign extends StatelessWidget {
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;
  final CurrentRider currentRiderController;

  ShipmentAddressDesign(
      {this.model,
      this.orderStatus,
      this.orderId,
      this.sellerId,
      this.orderByUser})
      : currentRiderController = Get.put(CurrentRider());

  // Function to handle parcel shipment confirmation
  void confirmedParcelShipment(BuildContext context, String getOrderID,
      String sellerId, String purchaserId) {
    FirebaseFirestore.instance.collection("orders").doc(getOrderID).update({
      "riderUID": sharedPreferences!.getString("uid"),
      "riderName": sharedPreferences!.getString("name"),
      "status": "picking",
      "lat": position!.latitude,
      "lng": position!.longitude,
      "address": completeAddress,
    });

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ParcelPickingScreen(
    //               purchaserId: purchaserId,
    //               purchaserAddress: model!.fullAddress,
    //               purchaserLat: model!.lat,
    //               purchaserLng: model!.lng,
    //               sellerId: sellerId,
    //               getOrderID: getOrderID,
    //             )));
  }

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
                  Text(model!.name!),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Phone Number",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(model!.phoneNumber!),
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
            model!.fullAddress!,
            textAlign: TextAlign.justify,
          ),
        ),
        orderStatus == "ended"
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      UserLocation uLocation = UserLocation();
                      uLocation.getCurrentLocation();

                      confirmedParcelShipment(
                          context, orderId!, sellerId!, orderByUser!);
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RidersSplashScreen()));
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
