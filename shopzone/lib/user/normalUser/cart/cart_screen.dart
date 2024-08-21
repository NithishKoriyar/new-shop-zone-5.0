import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/cart/cart_item_design_widget.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/models/address.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';

class CartScreenUser extends StatefulWidget {
  @override
  State<CartScreenUser> createState() => _CartScreenUserState();
}

class _CartScreenUserState extends State<CartScreenUser> {
  final CurrentUser currentUserController = Get.put(CurrentUser());

  late String userName;
  late String userEmail;
  late String userID;
  late String userImg;

  Address? userAddress;
  bool isLoadingAddress = true; // Track loading state for address

  @override
  void initState() {
    super.initState();

    currentUserController.getUserInfo().then((_) {
      setUserInfo();
      fetchUserAddress(); // Fetch user address here
      setState(() {});
    });
  }

  void setUserInfo() {
    userName = currentUserController.user.user_name;
    userEmail = currentUserController.user.user_email;
    userID = currentUserController.user.user_id.toString();
    userImg = currentUserController.user.user_profile;
  }

  void fetchUserAddress() async {
    Uri requestUri = Uri.parse('${API.fetchAddress}?uid=$userID');
    print("Requesting URI: $requestUri");

    final response = await http.get(requestUri);

    if (response.statusCode == 200) {
      print("Data received: ${response.body}");
      var decodedData = json.decode(response.body);
      if (decodedData is List && decodedData.isNotEmpty) {
        setState(() {
          userAddress = Address.fromJson(decodedData[0]);
          isLoadingAddress = false; // Stop loading address
        });
      } else {
        print("No address found.");
        isLoadingAddress = false;
      }
    } else {
      print("Failed to load address.");
      isLoadingAddress = false;
    }
  }

  Stream<List<dynamic>> fetchCartItems() async* {
    print("Loading");
    const String apiUrl = API.cartView;
    final response = await http.post(Uri.parse(apiUrl), body: {'userID': userID});

    if (response.statusCode == 200) {
      final List<dynamic> fetchedItems = json.decode(response.body);
      yield fetchedItems;
      print("fetchedItems");
      print(fetchedItems);
    } else {
      print("Error fetching cart items");
      yield [];
    }
  }

  // Current location
  Future<void> getCurrentLocationAndFill() async {
    try {
      // Ensure the location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "Location services are disabled.");
        return;
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: "Location permissions are permanently denied, we cannot request permissions.");
        return;
      }

      // When permissions are granted, access the position of the device
      Position position = await Geolocator.getCurrentPosition();

      // Use the Geocoding package to decode the coordinates into an address
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String detailedAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        List<String> addressParts = detailedAddress.split(',').map((s) => s.trim()).toList();

        setState(() {
          userAddress = Address(
            flatHouseNumber: addressParts.length > 0 ? addressParts[0] : "",
            city: addressParts.length > 2 ? addressParts[2] : "",
            stateCountry: addressParts.length > 3 ? "${addressParts[3]}, ${addressParts.length > 4 ? addressParts[4] : ""}" : "",
            name: userName, // Assuming you want to use the user's name
            phoneNumber: userAddress?.phoneNumber, // Keep the existing phone number
          );
        });

        Fluttertoast.showToast(msg: "Address updated with current location");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get location: $e");
    }
  }

  void showAddressSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Delivery Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('${userAddress?.name ?? ''}, ${userAddress?.stateCountry ?? ''}'),
                subtitle: Text(
                    '${userAddress?.flatHouseNumber ?? ''}, ${userAddress?.streetNumber ?? ''}, ${userAddress?.city ?? ''}'),
                trailing: Radio(
                  value: true,
                  groupValue: true,
                  onChanged: (value) {
                    // When an address is selected, update the main screen's address and close the sheet
                    Navigator.of(context).pop();
                  },
                ),
                onTap: () {
                  // When the user taps this address, update the cart screen with this address
                  setState(() {
                    userAddress = Address(
                      flatHouseNumber: userAddress?.flatHouseNumber,
                      streetNumber: userAddress?.streetNumber,
                      city: userAddress?.city,
                      stateCountry: userAddress?.stateCountry,
                      name: userAddress?.name,
                      phoneNumber: userAddress?.phoneNumber,
                    );
                  });
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Use pincode to check delivery info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter pincode',
                  border: OutlineInputBorder(),
                  suffixIcon: ElevatedButton(
                    onPressed: () {
                      // Handle submit pincode
                    },
                    child: Text('Submit'),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  getCurrentLocationAndFill();
                  Navigator.of(context).pop(); // Close the bottom sheet after fetching location
                },
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Use my current location',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget buildAddressShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 20.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 20.0,
                    width: 150.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 20.0,
                    width: 100.0,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              width: 50.0,
              height: 20.0,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItemShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              color: Colors.grey,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 20.0,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 20.0,
                    width: 50.0,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
        elevation: 20,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: isLoadingAddress
                      ? buildAddressShimmer() // Show shimmer effect while loading address
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (userAddress != null) ...[
                              Text(
                                userAddress!.name ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${userAddress!.flatHouseNumber ?? ''}, ${userAddress!.streetNumber ?? ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${userAddress!.city ?? ''}, ${userAddress!.stateCountry ?? ''}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                userAddress!.phoneNumber ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ] else ...[
                              Text(
                                'Loading address...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                TextButton(
                  onPressed: () {
                    showAddressSelectionSheet(context);
                  },
                  child: Text(
                    "Change",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: fetchCartItems(),
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5, // Show 5 shimmer placeholders while loading
                    itemBuilder: (context, index) {
                      return buildCartItemShimmer(); // Show shimmer effect for cart items
                    },
                  );
                } else if (!dataSnapshot.hasData || dataSnapshot.data!.isEmpty) {
                  return Center(child: Text('No items exist in the cart'));
                } else {
                  List<dynamic> cartItems = dataSnapshot.data!;
                  return ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      Carts model = Carts.fromJson(cartItems[index] as Map<String, dynamic>);
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
          ),
        ],
      ),
    );
  }
}
