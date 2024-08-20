import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/addressScreens/address_design_widget.dart';
import 'package:shopzone/user/normalUser/addressScreens/save_new_address_screen.dart';
import 'package:shopzone/user/normalUser/assistantMethods/address_changer.dart';
import 'package:shopzone/user/models/address.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';

// ignore: must_be_immutable
class AddressScreen extends StatefulWidget {
  Carts? model;

  AddressScreen({this.model});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
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
    print('user ID: $userID');
    print('user image: $userImg');
  }

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
      body: Column(
        children: [
          Expanded(
            child: Consumer<NormalUserAddressChanger>(builder: (context, address, c) {
              return StreamBuilder<List<dynamic>>(
                stream: fetchAddressStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        itemBuilder: (context, index) {
                          return AddressDesignWidget(
                            addressModel: Address.fromJson(snapshot.data![index]),
                            index: address.count,
                            value: index,
                            addressID: snapshot.data![index]['id'],
                            sellerUID: widget.model?.sellerUID,
                            totalPrice: widget.model?.totalPrice,
                            cartId: widget.model?.cartId,
                            model: widget.model,
                          );
                        },
                        itemCount: snapshot.data!.length,
                      );
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No address found."),
                      );
                    } else {
                      return Container();
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            }),
          ),
          Divider(thickness: 1, color: Colors.grey[300]),
          // Display Buy Now Item
          if (widget.model != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.model!.itemTitle ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Size: ${widget.model!.sizeName ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Qty: ${widget.model!.itemCounter}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '₹${widget.model!.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          // Add New Address Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => SaveNewAddressScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Button background color
                padding: EdgeInsets.symmetric(vertical: 16), // Button height
              ),
              child: Text(
                "Add New Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<dynamic>> fetchAddressStream() async* {
    while (true) {
      Uri requestUri = Uri.parse('${API.fetchAddress}?uid=$userID');
      print("Requesting URI: $requestUri");

      final response = await http.get(requestUri);

      if (response.statusCode == 200) {
        print("Data received: ${response.body}");

        var decodedData = json.decode(response.body);
        if (decodedData is List) {
          yield decodedData;
        } else {
          yield [];
        }
      } else {
        throw Exception('Failed to load address');
      }

      await Future.delayed(Duration(seconds: 10));
    }
  }
}
