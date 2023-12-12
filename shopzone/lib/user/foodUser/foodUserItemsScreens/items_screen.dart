import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/foodUser/foodUserItemsScreens/items_ui_design_widget.dart';
import 'package:shopzone/user/models/brands.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/foodUser/foodUserWidgets/text_delegate_header_widget.dart';
import 'package:http/http.dart' as http;


// ignore: must_be_immutable
class ItemsScreen extends StatefulWidget
{
  Brands? model;

  ItemsScreen({this.model,});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}



class _ItemsScreenState extends State<ItemsScreen>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors:
                [
                  Colors.black,
                  Colors.black,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              )
          ),
        ),
        title: const Text(
          "Food Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [

          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(title: widget.model!.brandTitle.toString() + "'s Items"),
          ),

          //1. query
          //2. model
          //3. ui design widget

          StreamBuilder(
            // We're emulating the stream using a FutureBuilder and StreamController
            stream: _fetchItems(),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> dataSnapshot) {
              if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
                return SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 1,
                  staggeredTileBuilder: (c) => const StaggeredTile.fit(1),
                  itemBuilder: (context, index) {
                    Items itemsModel = Items.fromJson(dataSnapshot.data![index]);
                    return ItemsUiDesignWidget(
                      model: itemsModel,
                    );
                  },
                  itemCount: dataSnapshot.data!.length,
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      "No items exists",
                    ),
                  ),
                );
              }
            },
          )

        ],
      ),
    );
  }
  Stream<List<Map<String, dynamic>>> _fetchItems() async* {
    final response = await http.get(Uri.parse(
        '${API.foodUserSellerMenuItemView}?sellerUID=${widget.model!.sellerUID}&brandID=${widget.model!.brandID}'));

    if (response.statusCode == 200) {
      var data = (json.decode(response.body) as List)
          .cast<Map<String, dynamic>>();
      yield data;
    } else {
      throw Exception('Failed to load items');
    }
  }

}
