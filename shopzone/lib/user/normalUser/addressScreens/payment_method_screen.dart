// import 'package:flutter/material.dart';
// import 'package:shopzone/user/normalUser/placeOrderScreen/place_order_screen.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PaymentMethodScreen extends StatefulWidget {
//   const PaymentMethodScreen({super.key});

//   @override
//   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// }

// class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
//   int _type = 1;

//   void _handleGooglePay(Object? e) {
//     setState(() {
//       _type = e as int;
//       if (_type == 1) {
//         _launchGooglePay();
//       }
//     });
//   }

//   void _handlePhonePe(Object? e) {
//     setState(() {
//       _type = e as int;
//       if (_type == 2) {
//         _launchPhonePe();
//       }
//     });
//   }

//   void _handleCashOnDelivery(Object? e) {
//     setState(() {
//       _type = e as int;
//       // Additional logic for handling cash on delivery can be added here if needed
//     });
//   }

//   void _launchGooglePay() async {
//     const url = 'https://pay.google.com/';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   void _launchPhonePe() async {
//     const url = 'https://www.phonepe.com/';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 20,
//         title: const Text(
//           "Payment Method",
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: true,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             children: [
//               SizedBox(height: 20),
//               // Google Pay Container
//               GestureDetector(
//                 onTap: () {
//                   _handleGooglePay(1); // Set the value to 5 for Google Pay
//                 },
//                 child: Container(
//                   width: size.width,
//                   height: 55,
//                   margin: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     border: _type == 1
//                         ? Border.all(
//                             width: 2, color: Color.fromARGB(255, 31, 12, 11))
//                         : Border.all(width: 1, color: Colors.grey),
//                     borderRadius: BorderRadius.all(Radius.circular(6)),
//                     color: Colors.transparent,
//                   ),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Radio(
//                                 value: 1, // Set the value to 5 for Google Pay
//                                 groupValue: _type,
//                                 onChanged: _handleGooglePay,

//                                 activeColor: Color.fromARGB(255, 141, 48, 41),
//                               ),
//                               Text(
//                                 "Google Pay",
//                                 style: _type == 1
//                                     ? TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey)
//                                     : TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey,
//                                       ),
//                               ),
//                             ],
//                           ),
//                           Image.asset(
//                             "images/g_pay.png",
//                             width: 110,
//                             height: 70,
//                             fit: BoxFit.cover,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               //..
//               GestureDetector(
//                 onTap: () {
//                   _handlePhonePe(2); // Set the value to 2 for Phone Pay
//                 },
//                 child: Container(
//                   width: size.width,
//                   height: 55,
//                   margin: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     border: _type == 2
//                         ? Border.all(
//                             width: 2, color: Color.fromARGB(255, 31, 12, 11))
//                         : Border.all(width: 1, color: Colors.grey),
//                     borderRadius: BorderRadius.all(Radius.circular(6)),
//                     color: Colors.transparent,
//                   ),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Radio(
//                                 value: 2, // Set the value to 2 for Phone Pay
//                                 groupValue: _type,
//                                 onChanged: _handlePhonePe,
//                                 activeColor: Color.fromARGB(255, 141, 48, 41),
//                               ),
//                               Text(
//                                 "Phone Pay",
//                                 style: _type == 2
//                                     ? TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey)
//                                     : TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey,
//                                       ),
//                               ),
//                             ],
//                           ),
//                           Image.asset(
//                             "images/phone_pay.png",
//                             width: 80,
//                             height: 70,
//                             fit: BoxFit.cover,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 15),
//               // Cash on Delivery Container
//               GestureDetector(
//                 onTap: () {
//                   _handleCashOnDelivery(
//                       3); // Set the value to 3 for Cash on Delivery
//                 },
//                 child: Container(
//                   width: size.width,
//                   height: 55,
//                   margin:
//                       EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
//                   decoration: BoxDecoration(
//                     border: _type == 3
//                         ? Border.all(
//                             width: 2, color: Color.fromARGB(255, 31, 12, 11))
//                         : Border.all(width: 1, color: Colors.grey),
//                     borderRadius: BorderRadius.all(Radius.circular(6)),
//                     color: Colors.transparent,
//                   ),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Radio(
//                                 value: 3,
//                                 groupValue: _type,
//                                 onChanged: _handleCashOnDelivery,
//                                 activeColor: Color.fromARGB(255, 141, 48, 41),
//                               ),
//                               Text(
//                                 "Cash on Delivery",
//                                 style: _type == 3
//                                     ? TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey)
//                                     : TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                           Image.asset(
//                             "images/Cash.png",
//                             width: 80,
//                             height: 70,
//                             fit: BoxFit.cover,
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               //.....
//               SizedBox(height: 10),
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Bil Details",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               //..
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Item Total",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     Text(
//                       "\₹",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               //
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       // Nested Row for the text and icon
//                       children: [
//                         Text(
//                           "Delivery Fees | 5.5kms",
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.info_outline, color: Colors.grey),
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: Text("Delivery Fees Information"),
//                                   content: SingleChildScrollView(
//                                     child: ListBody(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text("Base Fee"),
//                                             Text("₹21.00"),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                             height: 10), // Spacing between rows
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Text("Additional Distance Fee"),
//                                             Text("₹5.00"),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       child: Text("Close"),
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                     Text(
//                       "\₹26.00", // Total fee, which is the sum of the base and additional fees
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Divider(
//                 height: 10,
//                 color: Colors.black,
//               ),
//               //..
//               SizedBox(height: 5),
//               // Container(
//               //   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       Text(
//               //         "Delevery Tip",
//               //         style: TextStyle(
//               //           fontSize: 15,
//               //           fontWeight: FontWeight.w500,
//               //           color: Colors.grey,
//               //         ),
//               //       ),
//               //       Text(
//               //         "Add tip",
//               //         style: TextStyle(
//               //           fontSize: 15,
//               //           fontWeight: FontWeight.w500,
//               //           color: Colors.orange,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               //
//               // Container(
//               //   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       Row(
//               //         // Nested Row for the text and icon
//               //         children: [
//               //           Text(
//               //             "platform fees",
//               //             style: TextStyle(
//               //               fontSize: 15,
//               //               fontWeight: FontWeight.w500,
//               //               color: Colors.grey,
//               //             ),
//               //           ),
//               //           IconButton(
//               //             icon: Icon(Icons.info_outline, color: Colors.grey),
//               //             onPressed: () {
//               //               showDialog(
//               //                 context: context,
//               //                 builder: (BuildContext context) {
//               //                   return AlertDialog(
//               //                     title: Text("What are Platform Fees?"),
//               //                     content: Text(
//               //                         "Platform fees are charges applied to cover the operational costs of our service, including technology maintenance, customer support, and platform security enhancements."),
//               //                     actions: [
//               //                       TextButton(
//               //                         child: Text("Close"),
//               //                         onPressed: () {
//               //                           Navigator.of(context).pop();
//               //                         },
//               //                       ),
//               //                     ],
//               //                   );
//               //                 },
//               //               );
//               //             },
//               //           )
//               //         ],
//               //       ),
//               //       Text(
//               //         "\₹5.00", // Total fee, which is the sum of the base and additional fees
//               //         style: TextStyle(
//               //           fontSize: 15,
//               //           fontWeight: FontWeight.w500,
//               //           color: Colors.grey,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),

//               // Container(
//               //   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       Row(
//               //         // Nested Row for the text and the icon
//               //         children: [
//               //           Text(
//               //             "GST and Restaurant Charges",
//               //             style: TextStyle(
//               //               fontSize: 15,
//               //               fontWeight: FontWeight.w500,
//               //               color: Colors.grey,
//               //             ),
//               //           ),
//               //           IconButton(
//               //             icon: Icon(Icons.info_outline, color: Colors.grey),
//               //             onPressed: () {
//               //               showDialog(
//               //                 context: context,
//               //                 builder: (BuildContext context) {
//               //                   return AlertDialog(
//               //                     title: Text("Detailed Charges"),
//               //                     content: SingleChildScrollView(
//               //                       child: ListBody(
//               //                         children: [
//               //                           Text("Restaurant GST: ₹2.10"),
//               //                           SizedBox(
//               //                               height:
//               //                                   10), // Adds space between lines
//               //                           Text("GST on Platform fee: ₹0.90"),
//               //                           SizedBox(
//               //                               height:
//               //                                   20), // More space before the explanation
//               //                           Text(
//               //                               "shopzone plays no role in taxes and charges levied by the government and the restaurant."),
//               //                         ],
//               //                       ),
//               //                     ),
//               //                     actions: [
//               //                       TextButton(
//               //                         child: Text("Close"),
//               //                         onPressed: () {
//               //                           Navigator.of(context).pop();
//               //                         },
//               //                       ),
//               //                     ],
//               //                   );
//               //                 },
//               //               );
//               //             },
//               //           ),
//               //         ],
//               //       ),
//               //       Text(
//               //         "\₹3", // Assuming this is the dynamically fetched total charges
//               //         style: TextStyle(
//               //           fontSize: 15,
//               //           fontWeight: FontWeight.w500,
//               //           color: Colors.grey,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               // Divider(
//               //   height: 20,
//               //   color: Colors.black,
//               // ),

//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "To Pay",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                     Text(
//                       "\₹",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//                 ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purpleAccent,
//                           padding: const EdgeInsets.all(8.0),
//                         ),
//                         onPressed: () {
//                           // Print the values of addressID, sellerUID, and totalAmount
//                           // print("addressID: ${widget.addressID}");
//                           // print("totalAmount: ${widget.totalPrice}");
//                           // print("cartId: ${widget.cartId}");

//                           // Send the user to Place Order Screen
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (c) => PlaceOrderScreen(
//                           //       sellerUID :widget.sellerUID,
//                           //       addressID: widget.addressID,
//                           //       totalAmount: widget.totalPrice,
//                           //       cartId: widget.cartId,
//                           //       model: widget.model,
//                           //     ),
//                           //   ),
//                           // );
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (c) => PlaceOrderScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text("Proceed"),
//                       ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
