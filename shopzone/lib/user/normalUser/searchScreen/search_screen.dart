import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/noConnectionPage.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/brands.dart'; // Assuming you have a Brands model
import 'package:shopzone/user/normalUser/itemsScreens/items_ui_design_widget.dart';
import 'package:shopzone/user/normalUser/brandsScreens/brands_ui_design_widget.dart'; // Assuming you have a Brands UIDesign widget
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchTerm = "";

  Future<Map<String, dynamic>> initializeSearching(String searchTerm) async {
    final response = await http.get(Uri.parse("${API.searchStores}?searchTerm=$searchTerm"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 20,
        automaticallyImplyLeading: true,
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              searchTerm = textEntered;
            });
          },
          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  // trigger search
                });
              },
              icon: const Icon(Icons.search),
              color: Colors.white,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: initializeSearching(searchTerm),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.hasData) {
            List<Items> items = (snapshot.data!['items'] as List).map((item) => Items.fromJson(item)).toList();
            List<Brands> brands = (snapshot.data!['brands'] as List).map((brand) => Brands.fromJson(brand)).toList();

            if (items.isEmpty && brands.isEmpty) {
              return const Center(child: Text("No record found."));
            } else {
              return Column(
                children: [
                  // Horizontal list for brands
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        Brands model = brands[index];
                        return BrandsUiDesignWidget(
                          model: model,
                        );
                      },
                    ),
                  ),
                  // Vertical list for items
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        Items itemsModel = items[index];
                        return ItemsUiDesignWidget(
                          model: itemsModel,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Center(child: NoConnectionPage());
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
