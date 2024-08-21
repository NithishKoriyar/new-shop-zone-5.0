import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/addressScreens/text_field_address_widget.dart';
import 'package:shopzone/user/normalUser/cart/cart_screen.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';

class SaveNewAddressScreen extends StatefulWidget {
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
      setState(() {});
    });
  }

  void setUserInfo() {
    userName = currentUserController.user.user_name;
    userEmail = currentUserController.user.user_email;
    userID = currentUserController.user.user_id.toString();
    userImg = currentUserController.user.user_profile;
  }

  Future<void> useCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          streetNumber.text = place.street ?? '';
          flatHouseNumber.text = place.subLocality ?? '';
          city.text = place.locality ?? '';
          stateCountry.text = "${place.administrativeArea}, ${place.country}";
        });

        Fluttertoast.showToast(msg: "Location retrieved successfully");
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
          "Shop Zone",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
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
                    hint: "Street Number",
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
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: useCurrentLocation,
                    icon: Icon(Icons.location_on),
                    label: Text("Use My Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 9, 66, 165), // Button color
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
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
                  Uri.parse(API.addNewAddress),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => CartScreenUser()));
                } else {
                  Fluttertoast.showToast(msg: "Error saving address.");
                }
              } else {
                Fluttertoast.showToast(msg: "Please enter a valid phone number.");
              }
            }
          },
          icon: Icon(Icons.save),
          label: Text("Save Now"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Button color
            padding: EdgeInsets.symmetric(vertical: 16), // Button height
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
