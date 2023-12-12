import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopzone/foodSeller/foodSellerPreferences/food_current_seller.dart';
import 'package:shopzone/foodSeller/models/food_orders.dart';
import 'package:shopzone/foodSeller/ordersScreens/food_seller_order_card.dart';
import '../../api_key.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

    //!seller information--------------------------------------
  final CurrentFoodSeller currentSellerController = Get.put(CurrentFoodSeller());

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

  Stream<List<dynamic>> fetchOrders() async* {
    // Assuming your API endpoint is something like this
    const String apiUrl = API.foodSellerSellerOrdersView;

    try {
      final response =
          await http.post(Uri.parse(apiUrl),body: {'sellerID': sellerID});
          print(API.foodSellerSellerOrdersView);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.black,
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
