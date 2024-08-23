import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/addressScreens/address_screen.dart';
import 'package:shopzone/user/normalUser/addressScreens/payment_method_screen.dart';
import 'package:shopzone/user/normalUser/assistantMethods/address_changer.dart';
import 'package:shopzone/user/models/address.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/normalUser/placeOrderScreen/place_order_screen.dart';
import 'package:http/http.dart' as http;

class AddressDesignWidget extends StatefulWidget {
  final Address? addressModel;
  final Carts? model;
  final int? index;
  final int? value;
  final String? addressID;
  final String? sellerUID;
  final String? cartId;
  final int? totalPrice;

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
  Future<void> _deleteAddress(int addressID) async {
    final url = Uri.parse(API.deleteAddress);
    final response =
        await http.post(url, body: {'address_id': addressID.toString()});

    if (response.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (c) => AddressScreen(
                    model: widget.model,
                  )));
      setState(() {});
    } else {
      print('Failed to delete address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Radio(
                  groupValue: widget.index,
                  value: widget.value!,
                  activeColor: Colors.pink,
                  onChanged: (val) {
                    Provider.of<NormalUserAddressChanger>(context, listen: false)
                        .showSelectedAddress(val);
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.addressModel!.name.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Phone: ${widget.addressModel!.phoneNumber.toString()}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.addressModel!.completeAddress.toString(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Buttons
            if (widget.value == Provider.of<NormalUserAddressChanger>(context).count)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 229, 122, 112), // Red color for delete button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        int? addressIdInt;
                        try {
                          addressIdInt = int.parse(widget.addressID!);
                          _deleteAddress(addressIdInt);
                        } catch (e) {
                          print("Error converting addressID to int: $e");
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 82, 226, 87), // Green color for proceed button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => PlaceOrderScreen(
                              sellerUID: widget.sellerUID,
                              addressID: widget.addressID,
                              totalAmount: widget.totalPrice,
                              cartId: widget.cartId,
                              model: widget.model,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Proceed"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
