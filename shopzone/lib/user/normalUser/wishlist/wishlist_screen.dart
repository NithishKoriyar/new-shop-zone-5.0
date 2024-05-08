// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/get_instance.dart';
// import 'package:shopzone/api_key.dart';
// import 'package:shopzone/user/models/wishlist.dart';
// import 'package:shopzone/user/normalUser/widgets/my_drawer.dart';
// import 'package:http/http.dart' as http;
// import 'package:shopzone/user/normalUser/wishlist/wishlist_item_design_widget.dart';
// import 'package:shopzone/user/userPreferences/current_user.dart';

// class FavoriteScreen extends StatefulWidget {
//   @override
//   _FavoriteScreenState createState() => _FavoriteScreenState();
// }

// class _FavoriteScreenState extends State<FavoriteScreen> {
//   List<int>? itemQuantityList;
//   final CurrentUser currentUserController = Get.put(CurrentUser());

//   late String userName;
//   late String userEmail;
//   late String userID;
//   late String userImg;

//   @override
//   void initState() {
//     super.initState();

//     currentUserController.getUserInfo().then((_) {
//       setUserInfo();
//       printUserInfo();
//       // Once the seller info is set, call setState to trigger a rebuild.
//       setState(() {});
//     });
//   }

//   void setUserInfo() {
//     userName = currentUserController.user.user_name;
//     userEmail = currentUserController.user.user_email;
//     userID = currentUserController.user.user_id.toString();
//     userImg = currentUserController.user.user_profile;
//   }

//   void printUserInfo() {
//     print('user Name: $userName');
//     print('user Email: $userEmail');
//     print('user ID: $userID'); // Corrected variable name
//     print('user image: $userImg');
//   }

//   List<dynamic> items = [];
//   bool isLoading = true;

//  Stream<List<dynamic>> fetchWishlistItems() async* {
//     // Assuming your API endpoint is something like this
//     print("Loading");
//     const String apiUrl = API.userSellerBrandwishlistView;
//     final response =
//         await http.post(Uri.parse(apiUrl), body: {'userID': userID});

//     if (response.statusCode == 200) {
//       final List<dynamic> fetchedItems = json.decode(response.body);
//       yield fetchedItems;
//       print("fetchedItems");
//       print(fetchedItems);
//     } else {
//       print("Error fetching cart items");
//       yield []; // yield an empty list or handle error differently
//     }
//   }


//   @override
//  Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: MyDrawer(),
//       appBar: AppBar(
//         title: Text("wishlist"),
//         elevation: 20,
//         centerTitle: true,
//       ),
//       body: StreamBuilder<List<dynamic>>(
//         stream: fetchWishlistItems(),
//         builder: (context, dataSnapshot) {
//           if (dataSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//                 child: CircularProgressIndicator()); // Show loading indicator
//           } else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
//             return Center(child: Text('No items exist in the cart'));
//           } else {
//             List<dynamic> cartItems = dataSnapshot.data!;
//             return ListView.builder(
//               itemCount: cartItems.length,
//               itemBuilder: (context, index) {
//                 Wishlist model =
//                     Wishlist.fromJson(cartItems[index] as Map<String, dynamic>);
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child:  WishlistItemDesignWidget(
//                     model: model,
//                     quantityNumber: model.itemCounter,
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }


// }
