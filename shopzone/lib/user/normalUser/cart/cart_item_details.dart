
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/addressScreens/address_screen.dart';
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';
import 'package:shopzone/user/normalUser/widgets/appbar_cart_badge.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ItemsDetailsScreen extends StatefulWidget {
  Carts? model;

  ItemsDetailsScreen({this.model});

  @override
  State<ItemsDetailsScreen> createState() => _ItemsDetailsScreenState();
}

class _ItemsDetailsScreenState extends State<ItemsDetailsScreen> {
  final CurrentUser currentUserController = Get.put(CurrentUser());

  late String userName;
  late String userEmail;
  late String userID;
  late String userImg;
  int counterLimit = 1;

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


  //!delete item from the cart list
  Future<void> removeItemFromCart(String userID, String itemID) async {
    final response = await http.post(
      Uri.parse(API.deleteItemFromCart),
      body: {
        'userId': userID,
        'itemId': itemID,
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Item removed successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Failed to remove item. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithCartBadge(
        sellerUID: widget.model!.sellerUID.toString(),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            onPressed: () {
              // Call the remove function
              removeItemFromCart(userID, widget.model!.itemID.toString())
                  .then((_) {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => CartScreenUser()));
              });
            },
            heroTag: "btn1",
            icon: const Icon(
              Icons.delete_sweep_outlined,
            ),
            label: const Text(
              "Remove",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.black,
          ),
          //!Buy now option
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                
                  context, MaterialPageRoute(builder: (c) => AddressScreen(
                    model: widget.model,
                    )));
            },
            heroTag: "btn2",
            icon: const Icon(
              Icons.shopping_cart,
            ),
            label: const Text(
              "Buy Now",
              style: TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Center(
                child: Text(
                  widget.model!.itemTitle.toString(),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Text(
                "Quantity :${widget.model!.itemCounter}",
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0),
              child: Text(
                widget.model!.longDescription.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "₹ ${widget.model!.price}",
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.green,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, right: 320.0),
              child: Divider(
                height: 1,
                thickness: 2,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Total Price : ₹ " + widget.model!.totalPrice.toString(),
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
