import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/noConnectionPage.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/sellers.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_ui_design_widget.dart';
import 'package:shopzone/user/normalUser/sellersScreens/sellers_ui_design_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String sellerNameText = "";

  Future<List<Sellers>> initializeSearchingStores(String textEnteredbyUser) async {
    final response = await http
        .get(Uri.parse("${API.searchStores}?searchTerm=$textEnteredbyUser"));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((seller) => Sellers.fromJson(seller)).toList();
    } else {
      throw Exception('Failed to load data.');
    }
  }

  Future<List<Items>> initializeSearchingItems(String textEnteredbyUser) async {
    final response = await http
        .get(Uri.parse("${API.searchStores}?searchTerm=$textEnteredbyUser"));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((item) => Items.fromJson(item)).toList();
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
              sellerNameText = textEntered;
            });
          },
          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              onPressed: () async {
                setState(() {
                  // trigger search
                });
              },
              icon: const Icon(Icons.search),
              color: Colors.white,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          initializeSearchingStores(sellerNameText),
          initializeSearchingItems(sellerNameText),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            List<Sellers> sellers = snapshot.data![0];
            List<Items> items = snapshot.data![1];

            if (sellers.isEmpty && items.isEmpty) {
              return const Center(
                child: Text("No record found."),
              );
            } else {
              return ListView.builder(
                itemCount: sellers.length + items.length,
                itemBuilder: (context, index) {
                  if (index < sellers.length) {
                    Sellers model = sellers[index];
                    return SellersUIDesignWidget(
                      model: model,
                    );
                  } else {
                    Items itemsModel = items[index - sellers.length];
                    return ItemsUiDesignWidget(
                      model: itemsModel,
                    );
                  }
                },
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: NoConnectionPage(),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
