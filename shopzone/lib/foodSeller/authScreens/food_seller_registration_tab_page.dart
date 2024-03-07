import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/foodSeller/brandsScreens/food_seller_home_screen.dart';
import 'package:shopzone/foodSeller/foodSellerPreferences/food_seller_preferences.dart';
import 'package:shopzone/foodSeller/models/food_seller.dart';
import '../widgets/food_seller_custom_text_field.dart';
import '../widgets/food_seller_loading_dialog.dart';
import 'package:http/http.dart' as http;

class RegistrationTabPage extends StatefulWidget {
  @override
  State<RegistrationTabPage> createState() => _RegistrationTabPageState();
}

class _RegistrationTabPageState extends State<RegistrationTabPage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  XFile? imageXFile;
  String? imagename;
  String? imagedata;
  File? imagepath;

  final ImagePicker _picker = ImagePicker();

  String usersImageUrl = "";

  // The ImagePicker
  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
      String? originalName = imageXFile?.path.split('/').last.split('.').first;
      String? extension = imageXFile?.path.split('.').last;

      // Get the current date and time and format it
      String formattedDateTime =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      // Combine the original name with the formatted date and time
      imagename = "${originalName}_$formattedDateTime.$extension";

      imagepath = File(imageXFile!.path);
      imagedata = base64Encode(imagepath!.readAsBytesSync());
    });
  }

  //! GET LOCATION
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    _fillAddressInput(position);
  }

  void _fillAddressInput(Position position) async {
    // Use Geolocator to get address from latitude and longitude
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    // Construct an address string
    String address =
        "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";

    // Set the address string to the locationTextEditingController
    locationTextEditingController.text = address;
  }

  //this function is send the image to the php code and it will upload to a folder with unique name
  Future<void> uploadImage() async {
    try {
      var res = await http.post(
        Uri.parse(API.foodSellerProfileImageSeller),
        body: {"data": imagedata, "name": imagename},
      );
      var response = jsonDecode(res.body);

      if (response["success"] == true) {
        //see if is sending response
        //print("Uploaded Image Path: ${response["path"]}");
        usersImageUrl = response["path"]; // Update the sellerImageUrl variable
      } else {
        print("Something went wrong");
      }
    } catch (e) {
      print(e);
    }
  }

  //this function is get current location
  //the form validation
  Future<void> formValidation() async {
    if (imageXFile == null) {
      Fluttertoast.showToast(msg: "Please select an image.");
    } else {
      if (passwordTextEditingController.text ==
          confirmPasswordTextEditingController.text) {
        if (confirmPasswordTextEditingController.text.isNotEmpty &&
            emailTextEditingController.text.isNotEmpty &&
            nameTextEditingController.text.isNotEmpty &&
            phoneTextEditingController.text.length == 10) {
          //if all the form is valid it will call this function
          authenticateSeller();
        } else {
          Fluttertoast.showToast(
              msg: "Please write the complete required info for Registration.");
        }
      } else {
        Fluttertoast.showToast(msg: "Password do not match.");
      }
    }
  }

  //this function send the sellers email to the php code and check is it all ready registered or not
  void authenticateSeller() async {
    try {
      var res = await http.post(
        Uri.parse(API.foodSellerValidateSellerEmail),
        body: {
          'seller_email': emailTextEditingController.text.trim(),
        },
      );

      if (res.statusCode == 200) {
        //from flutter app the connection with api to server - success
        var resBodyOfValidateEmail = jsonDecode(res.body);
        //if email is not registered it send back response ['emailFound'] ==true
        if (resBodyOfValidateEmail['emailFound'] == true) {
          Fluttertoast.showToast(
              msg: "Email is already in someone else use. Try another email.");
        } else {
          showDialog(
            context: context,
            builder: (c) {
              return LoadingDialogWidget(
                message: "Registering Account",
              );
            },
          );
          //if everything is successful then it call uploadImage function
          //start uploading image
          await uploadImage(); // Upload the image

          //registering the seller to database my Sql
          registerAndSaveUserRecord();
        }
      } else {
        print("failed to register");
      }
    } catch (e) {
      print("failed to register");
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //so this function will save the data in mysql
  registerAndSaveUserRecord() async {
    //here it send the data to the users_user.dart in sellers_madel and change
    //to the json format Go check users_user.dart

    Seller userModel = Seller(
      1,
      nameTextEditingController.text.trim(),
      emailTextEditingController.text.trim(),
      confirmPasswordTextEditingController.text.trim(),
      usersImageUrl,
      phoneTextEditingController.text.trim(),
      locationTextEditingController.text.trim(),
    );
    try {
      //here the data is sent to the php file
      var res = await http.post(
        //Api is class were its in api_sellers_app/users_api_connection.dart
        Uri.parse(API.foodSellerRegisterSeller),
        body: userModel.toJson(),
      );
      if (res.statusCode == 200) {
        //from flutter app the connection with api to server - success
        var resBodyOfSignUp = jsonDecode(res.body);
        print(res.body);
        if (resBodyOfSignUp['success'] == true) {
          //also get user data from php file as a response
          //its in json format so decode using User class and save data in sellerInfo variable
          Seller sellerInfo = Seller.fromJson(resBodyOfSignUp['sellerData']);
          //save sellerInfo to local Storage using Shared Prefrences inside /sellersPreferences/users_preferences.dart
          await RememberFoodSellerPrefs.storeSellerInfo(sellerInfo);

          //everything go good the user will be sent to SellersHomePage
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => HomeScreen()));
        } else {
          Fluttertoast.showToast(msg: "Error Occurred, Try Again.");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

    @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) => _showWelcomeDialog());
}

void _showWelcomeDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Welcome!"),
        content: const Text("Please use get location button instead of typing and stay inside the your shop to get exact location or else update the location After logged in"),
        actions: <Widget>[
          TextButton(
            child: Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),

            //get-capture image
            GestureDetector(
              onTap: () {
                _getImage();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile == null
                    ? null
                    : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        color: Colors.black,
                        size: MediaQuery.of(context).size.width * 0.20,
                      )
                    : null,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            //inputs form fields
            Form(
              key: formKey,
              child: Column(
                children: [
                  //name
                  CustomTextField(
                    textEditingController: nameTextEditingController,
                    iconData: Icons.person,
                    hintText: "Restaurant Name",
                    isObsecre: false,
                    enabled: true,
                    keyboardType: TextInputType.name,
                  ),

                  //email
                  CustomTextField(
                    textEditingController: emailTextEditingController,
                    iconData: Icons.email,
                    hintText: "Restaurant Email",
                    isObsecre: false,
                    enabled: true,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  //pass
                  CustomTextField(
                    textEditingController: passwordTextEditingController,
                    iconData: Icons.lock_person_sharp,
                    hintText: "Password",
                    isObsecre: true,
                    enabled: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),

                  //confirm pass
                  CustomTextField(
                    textEditingController: confirmPasswordTextEditingController,
                    iconData: Icons.lock,
                    hintText: "Confirm Password",
                    isObsecre: true,
                    enabled: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),

                  //phone
                  CustomTextField(
                    textEditingController: phoneTextEditingController,
                    iconData: Icons.phone,
                    hintText: "Phone",
                    isObsecre: false,
                    enabled: true,
                    keyboardType: TextInputType.phone,
                  ),

                  //location
                  CustomTextField(
                    textEditingController: locationTextEditingController,
                    iconData: Icons.location_on_rounded,
                    hintText: "Address",
                    isObsecre: false,
                    enabled: true,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),

            ElevatedButton(
                onPressed: _getCurrentLocation, child: Text('Get Location')),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                onPressed: () {
                  formValidation();
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
