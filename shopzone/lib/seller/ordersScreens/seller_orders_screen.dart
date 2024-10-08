import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopzone/seller/models/orders.dart';
import 'package:shopzone/seller/ordersScreens/seller_order_card.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import '../../api_key.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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

  Stream<List<dynamic>> fetchOrders() async* {
    const String apiUrl = API.sellerOrdersView;

    try {
      print("Seller ID: $sellerID");
      final response =
          await http.post(Uri.parse(apiUrl), body: {'sellerID': sellerID});

      print(API.sellerOrdersView);
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('error')) {
          print("Server Error: ${responseData['error']}");
          yield [];
        } else if (responseData.containsKey('orders')) {
          final List<dynamic> fetchedItems = responseData['orders'];
          yield fetchedItems;
          print(fetchedItems);
        } else {
          print("No orders found in the response.");
          yield [];
        }
      } else {
        print("Error fetching cart items");
        yield [];
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
            return const Center(child: Text('No Orders'));
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
