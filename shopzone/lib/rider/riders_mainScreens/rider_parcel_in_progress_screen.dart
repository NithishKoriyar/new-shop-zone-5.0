import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_widgets/rider_order_card.dart';
import 'package:shopzone/rider/riders_widgets/rider_simple_app_bar.dart';
import 'package:http/http.dart' as http;



class ParcelInProgressScreen extends StatefulWidget
{
  @override
  _ParcelInProgressScreenState createState() => _ParcelInProgressScreenState();
}



class _ParcelInProgressScreenState extends State<ParcelInProgressScreen>
{


  Stream<List<dynamic>> fetchOrders() async* {
    // Assuming your API endpoint is something like this
    const String apiUrl = API.foodSellerSellerOrdersView;

    try {
      final response =
          await http.post(Uri.parse(apiUrl),body: {'sellerID': sellerID});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parcel In Progress"),
         elevation: 20,
        centerTitle: true,
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: fetchOrders(),
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
                Orders model =
                    Orders.fromJson(orderItems[index] as Map<String, dynamic>);
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
    );
  }
}

