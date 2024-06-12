import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shopzone/api_key.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/foodUser/foodUserAddressScreens/address_screen.dart';
import 'package:shopzone/user/foodUser/foodUserAssistantMethods/address_changer.dart';
import 'package:shopzone/user/models/address.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/foodUser/foodUserPlaceOrderScreen/place_order_screen.dart';

// ignore: must_be_immutable
class AddressDesignWidget extends StatefulWidget {
  Address? addressModel;
  Carts? model;
  int? index;
  int? value;
  String? addressID;
  String? sellerUID;
  String? cartId;
  int? totalPrice;

  AddressDesignWidget({
    this.addressModel,
    this.model,
    this.index,
    this.value,
    this.addressID,
    this.sellerUID,
    this.totalPrice,
    this.cartId,
  });

  @override
  State<AddressDesignWidget> createState() => _AddressDesignWidgetState();
}

class _AddressDesignWidgetState extends State<AddressDesignWidget> {
Razorpay razorpay = Razorpay();

void _handlePaymentSuccess(PaymentSuccessResponse response) {
  // Do something when payment succeeds
}

void _handlePaymentError(PaymentFailureResponse response) {
  // Do something when payment fails
}


@override
void dispose() {
  // TODO: implement dispose
  super.dispose();

  try{
    razorpay.clear();
  } catch (e){
    print(e);
  }
}

  Future<void> _deleteAddress(int addressID) async {
    final url = Uri.parse(API.foodUserDeleteAddress);
    final response =
        await http.post(url, body: {'address_id': addressID.toString()});
    print(API.foodUserDeleteAddress);

    if (response.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => AddressScreen(
                    model: widget.model,
                  )));

      // Refresh the page
      setState(() {
        // Any state changes that should trigger a UI rebuild go here
        // For example, if you have a list of addresses, you would remove the address here.
      });
    } else {
      print('Failed to delete address');
    }
  }

  @override
  Widget build(BuildContext context) {
    
razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    return Card(
      color: Colors.white24,
      child: Column(
        children: [
          //address info
          Row(
            children: [
              Radio(
                groupValue: widget.index,
                value: widget.value!,
                activeColor: Colors.pink,
                onChanged: (val) {
                  //provider
                  Provider.of<AddressChanger>(context, listen: false)
                      .showSelectedAddress(val);
                },
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Table(
                      children: [
                        TableRow(
                          children: [
                            const Text(
                              "Name: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.addressModel!.name.toString(),
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              "Phone Number: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.addressModel!.phoneNumber.toString(),
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              "Full Address: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.addressModel!.completeAddress.toString(),
                            ),
                          ],
                        ),
                        const TableRow(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          //button
          widget.value == Provider.of<AddressChanger>(context).count
              ? Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the buttons horizontally
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Red color for delete button
                        ),
                        onPressed: () {
                          // Implement delete functionality here
                          int? addressIdInt;
                          try {
                            addressIdInt = int.parse(widget.addressID!);
                            _deleteAddress(addressIdInt);
                          } catch (e) {
                            print("Error converting addressID to int: $e");
                          }
// Pass the address ID to delete
                        },
                        child: const Text("Delete"),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          padding: const EdgeInsets.all(8.0),
                        ),
                        onPressed: () {
                          // Print the values of addressID, sellerUID, and totalAmount
                          print("addressID: ${widget.addressID}");
                          print("totalAmount: ${widget.totalPrice}");
                          print("cartId: ${widget.cartId}");

                          var options = {
  'key': 'rzp_test_xFDe0Osp6j1a8I',
  'amount': 100,
  'name': 'Akhila.',
  'description': 'Fine T-Shirt',
  'prefill': {
    'contact': '8888888888',
    'email': 'test@razorpay.com'
  }
};

                          // Send the user to Place Order Screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (c) => PlaceOrderScreen(
                          //       sellerUID: widget.sellerUID,
                          //       addressID: widget.addressID,
                          //       totalAmount: widget.totalPrice,
                          //       cartId: widget.cartId,
                          //       model: widget.model,
                          //     ),
                          //   ),
                          // );
                          razorpay.open(options);
                          
                        },
                        child: const Text("Proceed"),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
