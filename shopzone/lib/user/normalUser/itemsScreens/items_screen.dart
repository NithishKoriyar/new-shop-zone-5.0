import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/brands.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_ui_design_widget.dart';
import 'package:shopzone/user/models/items.dart';
import '../widgets/text_delegate_header_widget.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ItemsScreen extends StatefulWidget {
  Brands? model;

  ItemsScreen({this.model});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(
              title: widget.model!.brandTitle.toString() + "'s Items",
            ),
          ),

          StreamBuilder(
            stream: _fetchItems(),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: _buildShimmerEffect(),
                );
              } else if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
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
                      "No items exist",
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _fetchItems() async* {
    final response = await http.get(Uri.parse(
        '${API.userSellerBrandItemView}?sellerUID=${widget.model!.sellerUID}&brandID=${widget.model!.brandID}'));

    if (response.statusCode == 200) {
      var data = (json.decode(response.body) as List)
          .cast<Map<String, dynamic>>();
      yield data;
    } else {
      throw Exception('Failed to load items');
    }
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
