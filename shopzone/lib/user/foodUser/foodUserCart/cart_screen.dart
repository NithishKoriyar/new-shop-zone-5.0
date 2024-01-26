import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/foodUser/foodUserCart/cart_item_design_widget.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/foodUser/foodUserWidgets/my_drawer.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:http/http.dart' as http;

class CartScreenUser extends StatefulWidget {
  @override
  State<CartScreenUser> createState() => _CartScreenUserState();
}

class _CartScreenUserState extends State<CartScreenUser> {
  List<int>? itemQuantityList;
  final CurrentUser currentUserController = Get.put(CurrentUser());

  late String userName;
  late String userEmail;
  late String userID;
  late String userImg;

  @override
  void initState() {
    super.initState();

    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      printUserInfo();
      // Once the seller info is set, call setState to trigger a rebuild.
      setState(() {});
    });
  }

  void setUserInfo() {
    userName = currentUserController.user.user_name;
    userEmail = currentUserController.user.user_email;
    userID = currentUserController.user.user_id.toString();
    userImg = currentUserController.user.user_profile;
  }

  void printUserInfo() {
    print('user Name: $userName');
    print('user Email: $userEmail');
    print('user ID: $userID'); // Corrected variable name
    print('user image: $userImg');
  }

  List<dynamic> cartItems = []; // Class-level variable to store cart items
  bool isLoading = true;

  Stream<List<dynamic>> fetchCartItems() async* {
    print("Loading");
    const String apiUrl = API.foodUserCartView;
    print(API.foodUserCartView);
    final response =
        await http.post(Uri.parse(apiUrl), body: {'userID': userID});

    if (response.statusCode == 200) {
      final List<dynamic> fetchedItems = json.decode(response.body);
      cartItems = fetchedItems; // Update the class-level cartItems variable
      yield fetchedItems;
      print("fetchedItems");
      print(fetchedItems);
    } else {
      print("Error fetching cart items");
      yield []; // yield an empty list or handle error differently
    }
  }

  void _orderAll() {
    // Loop through all cart items and print them
    print("--------------------------------");
    for (var item in cartItems) {
      
      print(item.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text("Cart"),
        elevation: 20,
        centerTitle: true,
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: fetchCartItems(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
            return const Center(
              child: Text('No items exist in the cart'),
            );
          } else {
            List<dynamic> cartItems = dataSnapshot.data!;
            return ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                Carts model =
                    Carts.fromJson(cartItems[index] as Map<String, dynamic>);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CartItemDesignWidget(
                    model: model,
                    quantityNumber: model.itemCounter,
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _orderAll();
        },
        icon: const Icon(Icons.check_circle),
        label: const Text("Order All"),
      ),
    );
  }
}
