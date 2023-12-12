import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/models/orders.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import '../ordersScreens/seller_order_card.dart';
import 'package:http/http.dart' as http;



class HistoryScreen extends StatefulWidget
{
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}



class _HistoryScreenState extends State<HistoryScreen> {
      //!seller information--------------------------------------
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


  List<dynamic> items = [];
  bool isLoading = true;

  Stream<List<dynamic>> fetchEndedOrders() async* {
    // Assuming your API endpoint is something like this
    const String apiUrl = API.endedOrdersView;

    try {
      final response =
          await http.post(Uri.parse(apiUrl),body: {'sellerID': sellerID});

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
  Widget build(BuildContext context) {
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
          "History",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: fetchEndedOrders(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
            return const Center(
                child: Text('No Shifted Orders')); // Show loading indicator
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
