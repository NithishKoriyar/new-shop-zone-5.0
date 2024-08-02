import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopzone/seller/models/seller_items.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import 'package:shopzone/seller/splashScreen/seller_my_splash_screen.dart';
import 'package:http/http.dart' as http;
import '../../api_key.dart';

// ignore: must_be_immutable
class ItemsDetailsScreen extends StatefulWidget {
  Items? model;

  ItemsDetailsScreen({
    this.model,
  });


  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();

}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {

  Future<void> deleteItem(String brandUniqueID,String itemID, String thumbnailUrl) async {
    //Uri.parse("${API.currentSellerBrandView}?sellerID=$sellerID")
    var url = Uri.parse(
        "${API.deleteItems}?brandUniqueID=$brandUniqueID&itemID=$itemID&uid=$sellerID&thumbnailUrl=$thumbnailUrl");
    print(url);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["status"] == "success") {
        Fluttertoast.showToast(msg: jsonResponse["message"]);
        Navigator.push(context, MaterialPageRoute(builder: (c) => SellerSplashScreen()));
      } else {
        Fluttertoast.showToast(msg: jsonResponse["message"]);
      }
    } else {
      Fluttertoast.showToast(msg: "Network error.");
    }
  }
      //!seller information
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;


  @override
    void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
      printSellerInfo();
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
  }

  void printSellerInfo() {
    print("-Brand items Screens-");
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller Email: $sellerID');
  }

  //!seller information--------------------------------------
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
elevation: 20,
        title: Text(
          widget.model!.itemTitle.toString(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          deleteItem(widget.model!.brandID.toString(),
              widget.model!.itemID.toString(),
              widget.model!.thumbnailUrl.toString());
        },
        label: const Text("Delete this Item"),
        icon: const Icon(
          Icons.delete_sweep_outlined,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
            height: 400,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Text(
                widget.model!.itemTitle.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                widget.model!.longDescription.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "₹ " + widget.model!.price.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.green,
                ),
              ),
            ),
          ),
            Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Size Name: ${widget.model!.SizeName ?? ''}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
           Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Colour Name: ${widget.model!.ColourName ?? ''}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 0, right: 0),
            child: Divider(
              height: 1,
              thickness: 2,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
