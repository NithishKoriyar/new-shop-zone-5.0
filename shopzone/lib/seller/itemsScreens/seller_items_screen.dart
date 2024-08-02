import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/noConnectionPage.dart';
import 'package:shopzone/seller/itemsScreens/seller_items_ui_design_widget.dart';
import 'package:shopzone/seller/itemsScreens/seller_upload_items_screen.dart';
import 'package:shopzone/seller/models/seller_items.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';

import '../models/seller_brands.dart';
import '../widgets/seller_text_delegate_header_widget.dart';

// ignore: must_be_immutable
class ItemsScreen extends StatefulWidget {
  Brands? model;

  ItemsScreen({
    this.model,
  });

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  //!seller information
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
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
  }

  void printSellerInfo() {
    print("-------Brand items Screens-------");
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller Email: $sellerID');
  }

  //!seller information--------------------------------------
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Shop Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => UploadItemsScreen(
                    model: widget.model,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.add_box_rounded,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(
                title: widget.model!.brandTitle.toString()),
          ),

          //1. query
          //2. model
          //3. ui design widget

          StreamBuilder<List<Items>>(
            stream: getItemsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 1,
                  staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                  itemBuilder: (context, index) {
                    final itemsModel = snapshot.data![index];
                    return ItemsUiDesignWidget(
                        model: itemsModel, context: context);
                  },
                  itemCount: snapshot.data!.length,
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: NoConnectionPage()),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text("No items exist "),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  Stream<List<Items>> getItemsStream() async* {
    final String uid = sellerID;
    final String brandID = widget.model!.brandID!;

    print("---Brand__");
    print(brandID);

    final url = "${API.getItems}?uid=$uid&brandID=$brandID";

    try {
      print(url);
      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(response.body);

      print(jsonData);
      print(response);

      if (jsonData['status'] == 'success') {
        print("items");
        final items = List<Items>.from(
            jsonData['data'].map((item) => Items.fromJson(item)));
        yield items;
      } else {
        print("status is not success");
        throw jsonData['message'];
      }
    } catch (e) {
      // Handle any other exceptions that may arise and propagate them as errors in the stream.
      yield* Stream.error(e);
      print("Error: ");
    }
  }
}
// final url = "${API.getItems}?uid=$uid&brandID=$brandID";
