import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/sellers.dart';
import 'package:shopzone/user/normalUser/sellersScreens/sellers_ui_design_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String sellerNameText = "";
  Future<QuerySnapshot>? storesDocumentsList;

  Future<List<Sellers>> initializeSearchingStores(
      String textEnteredbyUser) async {
    final response = await http
        .get(Uri.parse("${API.searchStores}?searchTerm=$textEnteredbyUser"));

    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((seller) => Sellers.fromJson(seller)).toList();
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
            hintText: "Search Seller here...",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: IconButton(
              onPressed: () async {
                setState(() {
                  initializeSearchingStores(sellerNameText);
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
      body: FutureBuilder<List<Sellers>>(
        future: initializeSearchingStores(sellerNameText),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Sellers model = snapshot.data![index];

                    return SellersUIDesignWidget(
                      model: model,
                    );
                  },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            return const Center(
              child: Text("No record found."),
            );
          }
        },
      ),
    );
  }
}
