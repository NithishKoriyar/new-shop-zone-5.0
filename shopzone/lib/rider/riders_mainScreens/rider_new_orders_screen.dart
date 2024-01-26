import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_widgets/rider_order_card.dart';
import 'package:shopzone/rider/riders_widgets/rider_simple_app_bar.dart';
import 'package:shopzone/rider/riders_widgets/riders_progress_bar.dart';
import 'package:http/http.dart' as http;

class NewOrdersScreen extends StatefulWidget {
  @override
  _NewOrdersScreenState createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  Stream<List<dynamic>> fetchOrdersInRDR() async* {
    // Assuming your API endpoint is something like this
    const String apiUrl = API.normalOrdersRDR;

    try {
      final response = await http.post(Uri.parse(apiUrl));
      // Removed the body part that was sending sellerID

      print(API.sellerOrdersView);
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Orders"),
          elevation: 20,
        ),
      body: StreamBuilder<List<dynamic>>(
        stream: fetchOrdersInRDR(),
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
                    orderID: model.orderId,
                  ),
                );
              },
            );
          }
        },
      ),
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shopzone/rider/riders_widgets/rider_order_card.dart';
// import 'package:shopzone/rider/riders_widgets/rider_simple_app_bar.dart';
// import 'package:shopzone/rider/riders_widgets/riders_progress_bar.dart';
// import 'package:http/http.dart' as http;

// class NewOrdersScreen extends StatefulWidget {
//   @override
//   _NewOrdersScreenState createState() => _NewOrdersScreenState();
// }

// class _NewOrdersScreenState extends State<NewOrdersScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           appBar: AppBar(
//             title: Text("New Orders"),
//             elevation: 20,
//           ),
//           body: StreamBuilder(
//             stream: Stream.periodic(
//                     Duration(seconds: 30)) // Polling every 30 seconds
//                 .asyncMap((_) =>
//                     http.get(Uri.parse('http://localhost:3000/getOrders'))),
//             builder: (context, AsyncSnapshot<http.Response> snapshot) {
//               if (snapshot.hasData && snapshot.data!.statusCode == 200) {
//                 var data = json.decode(snapshot.data!.body);

//                 return ListView.builder(
//                   itemCount: data.length,
//                   itemBuilder: (context, index) {
//                     var order = data[index];

//                     // Assuming you have a similar function to fetch item details
//                     return FutureBuilder<http.Response>(
//                       future: http.get(Uri.parse(
//                           'http://localhost:3000/getOrderItems.php?orderID=${order['id']}')),
//                       builder:
//                           (context, AsyncSnapshot<http.Response> itemSnapshot) {
//                         if (itemSnapshot.hasData &&
//                             itemSnapshot.data!.statusCode == 200) {
//                           var itemData = json.decode(itemSnapshot.data!.body);

                          // return OrderCard(
                          //   itemCount: itemData.length,
                          //   data: itemData,
                          //   orderID: order['id'],
                          //   // ... other properties
                          // );
//                         } else {
//                           return Center(child: CircularProgressIndicator());
//                         }
//                       },
//                     );
//                   },
//                 );
//               } else {
//                 return Center(child: CircularProgressIndicator());
//               }
//             },
//           )),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:shopzone/rider/riders_widgets/rider_order_card.dart';
// import 'package:shopzone/rider/riders_widgets/rider_simple_app_bar.dart';
// import 'package:shopzone/rider/riders_widgets/riders_progress_bar.dart';

// class NewOrdersScreen extends StatefulWidget {
//   @override
//   _NewOrdersScreenState createState() => _NewOrdersScreenState();
// }

// class _NewOrdersScreenState extends State<NewOrdersScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("New Orders"),
//           elevation: 20,
//         ),
//         body: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection("orders")
//               .where("status", isEqualTo: "normal")
//               .orderBy("orderTime", descending: true)
//               .snapshots(),
//           builder: (c, snapshot)
//           {
//             return snapshot.hasData
//                 ? ListView.builder(
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (c, index)
//                     {
//                       return FutureBuilder<QuerySnapshot>(
//                         future: FirebaseFirestore.instance
//                             .collection("items")
//                             .where("itemID", whereIn: separateOrderItemIDs((snapshot.data!.docs[index].data()! as Map<String, dynamic>) ["productIDs"]))
//                             .where("orderBy", whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"])
//                             .orderBy("publishedDate", descending: true)
//                             .get(),
//                         builder: (c, snap)
//                         {
//                           return snap.hasData
//                               ? OrderCard(
//                             itemCount: snap.data!.docs.length,
//                             data: snap.data!.docs,
//                             orderID: snapshot.data!.docs[index].id,
//                             seperateQuantitiesList: separateOrderItemQuantities((snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productIDs"]),
//                           )
//                               : Center(child: circularProgress());
//                         },
//                       );
//                     },
//                   )
//                 : Center(child: circularProgress(),);
//           },
//         ),
//       ),
//     );
//   }
// }
