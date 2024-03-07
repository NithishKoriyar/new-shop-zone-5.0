import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_widgets/rider_order_card.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class NewOrdersScreen extends StatefulWidget {
  @override
  _NewOrdersScreenState createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {



 Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
        msg: "Enable location",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: const Color.fromARGB(255, 0, 0, 0),
        fontSize: 16.0
    );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can get the location
    return await Geolocator.getCurrentPosition();
  }



  Stream<List<dynamic>> fetchOrdersInRDR() async* {
            Position position = await getCurrentLocation();
      double latitude = position.latitude;
      double longitude = position.longitude;
    // Assuming your API endpoint is something like this
     String apiUrl = '${API.normalOrdersRDR}?lat=$latitude&lng=$longitude';

    try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
    );
      print("Response Body: ${response.body}");
      print('latitude ${latitude}');
      print('longitude ${longitude}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('error')) {
          // If there's an error message in the response
          print("Server Error : ${responseData['error']}");
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
      // Handle exceptio
      print("--------------------------------------------------------------");
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
                  Orders model = Orders.fromJson(
                      orderItems[index] as Map<String, dynamic>);
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
      ),
    );
  }
}
