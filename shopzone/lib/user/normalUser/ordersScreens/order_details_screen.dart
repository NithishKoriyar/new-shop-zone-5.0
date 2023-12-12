import 'package:flutter/material.dart';
import 'package:shopzone/user/models/orders.dart';
import 'package:shopzone/user/normalUser/ordersScreens/address_design_widget.dart';

// ignore: must_be_immutable
class OrderDetailsScreen extends StatefulWidget {
  Orders? model;

  OrderDetailsScreen({this.model});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String orderStatus = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: widget.model != null
            ? Column(
                children: [
                  SizedBox(height: 30,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "₹ " + widget.model!.totalAmount.toString(),
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
                        "Order ID = " + widget.model!.orderId.toString(),
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
                        "Order at = ${widget.model!.orderTime}",
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
                  widget.model!.orderStatus == "ended"
                      ? Image.asset("images/delivered.png")
                      : Image.asset("images/state.png"),
                  const Divider(
                    thickness: 1,
                    color: Colors.pinkAccent,
                  ),
                 AddressDesign(
                  model: widget.model,
                 )


                ],
              )
            : const Center(
                child: Text(
                  "No data exists.",
                ),
              ),
      ),
    );
  }
}
