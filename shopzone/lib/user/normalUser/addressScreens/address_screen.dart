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
import 'package:shopzone/user/normalUser/placeOrderScreen/place_order_screen.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';

class AddressScreen extends StatefulWidget {
  Carts? model;
  int? quantity;
  String? price;
  String? sellingPrice;
  String? totalPrice;
  String? calculateDiscount;

  AddressScreen({
    this.model,
    this.quantity,
    this.price,
    this.sellingPrice,
    this.totalPrice,
    this.calculateDiscount,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final CurrentUser currentUserController = Get.put(CurrentUser());
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _priceDetailsKey = GlobalKey();

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

  void _scrollToPriceDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        _priceDetailsKey.currentContext!,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
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
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 100), // Space for the bottom bar
            child: Column(
              children: [
                // Address List
                Consumer<NormalUserAddressChanger>(builder: (context, address, c) {
                  return StreamBuilder<List<dynamic>>(
                    stream: fetchAddressStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Column(
                            children: snapshot.data!.map((item) {
                              return AddressDesignWidget(
                                addressModel: Address.fromJson(item),
                                index: address.count,
                                value: snapshot.data!.indexOf(item),
                                addressID: item['id'],
                                sellerUID: widget.model?.sellerUID,
                                totalPrice: widget.model?.totalPrice,
                                cartId: widget.model?.cartId,
                                model: widget.model,
                              );
                            }).toList(),
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
                Divider(thickness: 1, color: Colors.grey[300]),
                // Add New Address Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => SaveNewAddressScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 155, 198, 13),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Add New Address",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
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
                                    'Color: ${widget.model!.colourName ?? ''}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
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
                                    'Qty: ${widget.quantity}',
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
                        // Price Display
                        Row(
                          children: [
                            Text(
                              "₹${widget.sellingPrice}", // Selling price in bold green
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(width: 10), // Space between prices
                            if (widget.price != null)
                              Text(
                                "₹${widget.price}", // Original price with strike-through
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            SizedBox(width: 10), // Space between prices and discount
                            if (widget.price != null && widget.sellingPrice != null)
                              Text(
                                widget.calculateDiscount ?? '', // Discount percentage
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        Divider(thickness: 10, color: Colors.grey[300]),
                        SizedBox(height: 8),
                        // Price Details Section
                        Container(
                          key: _priceDetailsKey,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Price (${widget.quantity} item${widget.quantity! > 1 ? 's' : ''})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.price}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    '-₹${(double.parse(widget.price!) - double.parse(widget.sellingPrice!)).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Delivery Charges',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '₹40',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                      Text(
                                        ' FREE Delivery',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(thickness: 1, color: Colors.grey[300]),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '₹${widget.totalPrice}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                             Divider(thickness: 1, color: Colors.grey[300]),
                              SizedBox(height: 8),
                              // You will save section
                              Text(
                                'You will save ₹${(double.parse(widget.price!) - double.parse(widget.sellingPrice!)).toStringAsFixed(2)} on this order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Fixed Bottom Bar with View Price Details and Continue Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.price != null)
                        Text(
                          "${widget.sellingPrice}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      TextButton(
                        onPressed: _scrollToPriceDetails,
                        child: Text(
                          "View price ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 49, 61, 8),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => PlaceOrderScreen(
                            sellerUID: widget.model?.sellerUID,
                            addressID: widget.model?.cartId,
                            totalAmount: widget.model?.totalPrice,
                            cartId: widget.model?.cartId,
                            model: widget.model,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
