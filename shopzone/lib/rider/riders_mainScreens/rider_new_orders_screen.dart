import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_widgets/rider_order_card.dart';
import 'package:shopzone/rider/riders_widgets/rider_simple_app_bar.dart';
import 'package:shopzone/rider/riders_widgets/riders_progress_bar.dart';
import 'package:http/http.dart' as http;

class NewOrdersScreen extends StatefulWidget {
  @override
  _NewOrdersScreenState createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  
  Stream<List<dynamic>> fetchOrdersInRDR() async* {
    // Assuming your API endpoint is something like this
    const String apiUrl = API.normalOrdersRDR;

    try {
      final response = await http.post(Uri.parse(apiUrl));
      // Removed the body part that was sending sellerID

      print(API.sellerOrdersView);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('error')) {
          // If there's an error message in the response
          print("Server Error: ${responseData['error']}");
          yield []; // yield an empty list or handle error differently
        } else {
          final List<dynamic> fetchedItems = responseData['orders'] ?? [];
          // Assuming the fetched items are under the 'orders' key. Use a null check just in case.
          yield fetchedItems;
          print(fetchedItems);
        }
      } else {
        print("Error fetching cart items");
        yield []; // yield an empty list or handle error differently
      }
    } catch (e) {
      print("Exception while fetching orders: $e");
      yield [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Orders"),
          elevation: 20,
        ),
        body: StreamBuilder<List<dynamic>>(
          stream: fetchOrdersInRDR(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // Show loading indicator
            } else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No Orders')); // Show loading indicator
            } else {
              
              List<dynamic> orderItems = dataSnapshot.data!;
              return ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  Orders model = Orders.fromJson(
                      orderItems[index] as Map<String, dynamic>);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OrderCard(
                      model: model,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
