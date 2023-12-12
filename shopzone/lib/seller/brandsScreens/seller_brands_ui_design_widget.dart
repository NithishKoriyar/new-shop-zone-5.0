import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/seller/models/seller_brands.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import 'package:shopzone/seller/splashScreen/seller_my_splash_screen.dart';

import '../../api_key.dart';
import '../itemsScreens/seller_items_screen.dart';

// ignore: must_be_immutable
class BrandsUiDesignWidget extends StatefulWidget {
  Brands? model;
  BuildContext? context;

  BrandsUiDesignWidget({
    this.model,
    this.context,
  });

  @override
  State<BrandsUiDesignWidget> createState() => _BrandsUiDesignWidgetState();
}

class _BrandsUiDesignWidgetState extends State<BrandsUiDesignWidget> {
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;
  late String sellerImg;

  @override
  void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
      printSellerInfo();
      // Once the seller info is set, call setState to trigger a rebuild.
      setState(() {});
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
    sellerImg = currentSellerController.seller.seller_profile;
  }

  void printSellerInfo() {
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller ID: $sellerID'); // Corrected variable name
    print('Seller image: $sellerImg');
  }

  Future<void> deleteBrand(String brandUniqueID, String thumbnailUrl) async {
    //Uri.parse("${API.currentSellerBrandView}?sellerID=$sellerID")
    var url = Uri.parse(
        "${API.deleteBrand}?brandUniqueID=$brandUniqueID&uid=$sellerID&thumbnailUrl=$thumbnailUrl");

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ItemsScreen(
              model: widget.model,
            ),
          ),
        );
      },
      child: Card(
        elevation: 10,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 270,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Image.network(
                  API.brandImage + (widget.model!.thumbnailUrl ?? ''),
                  height: 220,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  height: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.model!.brandTitle.toString(),
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 3,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteBrand(widget.model!.brandID.toString(),
                            widget.model!.thumbnailUrl.toString());
                      },
                      icon: const Icon(
                        Icons.delete_sweep,
                        color: Colors.pinkAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
