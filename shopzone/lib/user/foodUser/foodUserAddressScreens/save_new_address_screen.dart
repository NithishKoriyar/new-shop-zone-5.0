import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/foodUser/foodUserAddressScreens/address_screen.dart';
import 'package:shopzone/user/foodUser/foodUserAddressScreens/text_field_address_widget.dart';
import 'package:shopzone/user/foodUser/foodUserCart/cart_screen.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';

// ignore: must_be_immutable
class SaveNewAddressScreen extends StatefulWidget {
  String? sellerUID;
  double? totalAmount;

  SaveNewAddressScreen();

  @override
  State<SaveNewAddressScreen> createState() => _SaveNewAddressScreenState();
}

class _SaveNewAddressScreenState extends State<SaveNewAddressScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController streetNumber = TextEditingController();
  TextEditingController flatHouseNumber = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController stateCountry = TextEditingController();
  String completeAddress = "";
  final formKey = GlobalKey<FormState>();

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
      getCurrentLocationAndFill();
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

  Future<void> getCurrentLocationAndFill() async {
    try {
      // Ensure the location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled. Don't continue
        // accessing the position and request users to enable the location services.
        Fluttertoast.showToast(msg: "Location services are disabled.");
        return;
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try requesting permissions again
          Fluttertoast.showToast(msg: "Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        Fluttertoast.showToast(
            msg:
                "Location permissions are permanently denied, we cannot request permissions.");
        return;
      }

      // When we reach here, permissions are granted and we can continue accessing the position of the device.
      Position position = await Geolocator.getCurrentPosition();

      // Use the Geocoding package to decode the coordinates into an address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        // Assuming the first result is the most relevant
        Placemark place = placemarks.first;
        String detailedAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        List<String> addressParts =
            detailedAddress.split(',').map((s) => s.trim()).toList();

        // Assuming the format is: "Flat/House Number, Street, City, State, Country"
        setState(() {
          flatHouseNumber.text = addressParts.length > 0 ? addressParts[0] : "";
          city.text = addressParts.length > 2 ? addressParts[2] : "";
          stateCountry.text = addressParts.length > 3
              ? "${addressParts[3]}, ${addressParts.length > 4 ? addressParts[4] : ""}"
              : "";
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to get location: $e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 20,
        title: const Text(
          "Food Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            if (phoneNumber.text.length == 10) {
              completeAddress = streetNumber.text.trim() +
                  ", " +
                  flatHouseNumber.text.trim() +
                  ", " +
                  city.text.trim() +
                  ", " +
                  stateCountry.text.trim() +
                  ".";

              var response = await http.post(
                Uri.parse(API.foodUserAddNewAddress),
                body: jsonEncode({
                  "uid": userID,
                  "name": name.text.trim(),
                  "phoneNumber": phoneNumber.text.trim(),
                  "streetNumber": streetNumber.text.trim(),
                  "flatHouseNumber": flatHouseNumber.text.trim(),
                  "city": city.text.trim(),
                  "stateCountry": stateCountry.text.trim(),
                  "completeAddress": completeAddress,
                }),
              );

              if (response.statusCode == 200) {
                var responseData = jsonDecode(response.body);
                Fluttertoast.showToast(msg: responseData['message']);
                formKey.currentState!.reset();
                // ignore: use_build_context_synchronously
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => CartScreenUser()));
              } else {
                Fluttertoast.showToast(msg: "Error saving address.");
              }
            } else {
              Fluttertoast.showToast(msg: "please enter valid phone number.");
            }
          }
        },
        label: const Text("Save Now"),
        icon: const Icon(
          Icons.save,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Text(
                "Save New Address:",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFieldAddressWidget(
                    hint: "Name",
                    controller: name,
                    keyboardType: TextInputType.name,
                  ),
                  TextFieldAddressWidget(
                    hint: "Phone Number",
                    controller: phoneNumber,
                    keyboardType: TextInputType.phone,
                  ),
                  TextFieldAddressWidget(
                    hint: "Room Number/House name",
                    controller: streetNumber,
                    keyboardType: TextInputType.text,
                  ),
                  TextFieldAddressWidget(
                    hint: "Flat / House Number",
                    controller: flatHouseNumber,
                    keyboardType: TextInputType.text,
                  ),
                  TextFieldAddressWidget(
                    hint: "City",
                    controller: city,
                    keyboardType: TextInputType.text,
                  ),
                  TextFieldAddressWidget(
                    hint: "State / Country",
                    controller: stateCountry,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
            ),
            FloatingActionButton.extended(
              onPressed: getCurrentLocationAndFill,
              icon: const Icon(Icons.location_on), // The icon
              label: const Text('Get Location',style: TextStyle(color: Colors.blue),), // The label
              tooltip: 'Get Location',
              backgroundColor: Color.fromARGB(255, 255, 225, 0),
            ),
          ],
        ),
      ),
    );
  }
}
