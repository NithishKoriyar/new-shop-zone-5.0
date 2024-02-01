import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_model/rider_address.dart';
import 'package:shopzone/rider/riders_widgets/rider_shipment_address_design.dart';
import 'package:shopzone/rider/riders_widgets/rider_status_banner.dart';
import 'package:shopzone/rider/riders_widgets/riders_progress_bar.dart';

class OrderDetailsScreen extends StatefulWidget {
  Orders? model;

  OrderDetailsScreen({
    super.key,
    this.model,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
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
        printSellerInfo();
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

  void printSellerInfo() {
    print('Seller Name: $riderName');
    print('Seller Email: $riderEmail');
    print('Seller ID: $riderID'); // Corrected variable name
    print('Seller image: $riderImg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "₹ ${widget.model?.totalAmount}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Order ID = ${widget.model?.orderId}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Order at = ${widget.model?.orderTime}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              color: Colors.pinkAccent,
            ),
            widget.model?.orderStatus != "ended"
                ? Image.asset("images/packing.jpg")
                : Image.asset("images/delivered.jpg"),
            const Divider(
              thickness: 1,
              color: Colors.pinkAccent,
            ),
            ShipmentAddressDesign(model: widget.model),
          ],
        ),
      ),
    );
  }
}
