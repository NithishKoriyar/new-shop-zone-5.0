import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopzone/api_key.dart';
import '../ridersPreferences/riders_preferences.dart';
import '../riders_mainScreens/riders_home_screen.dart';
import '../riders_widgets/riders_custom_text_field.dart';
import '../riders_widgets/riders_error_dialog.dart';
import '../riders_widgets/riders_loading_dialog.dart';
import '../riders_model/riders_user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  String? imagename;
  String? imagedata;
  File? imagepath;

  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;
  String usersImageUrl = "";
  String completeAddress = "";

// The ImagePicker
  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
      imagename = imageXFile?.path.split('/').last;
      imagepath = File(imageXFile!.path);
      imagedata = base64Encode(imagepath!.readAsBytesSync());
      // print("hello:" + imagedata.toString());
    });
  }

  //this function is send the image to the php code and it will upload to a folder with unique name
  Future<void> uploadImage() async {
    try {
      var res = await http.post(
        Uri.parse(API.upProfileImage),
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
  getCurrentLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress =
        '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  //the form validation
  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return const RidersErrorDialog(
              message: "Please select an image.",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          //if all the form is valid it will call this function
          authenticateRider();
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return const RidersErrorDialog(
                  message:
                      "Please write the complete required info for Registration.",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const RidersErrorDialog(
                message: "Password do not match.",
              );
            });
      }
    }
  }

//this function send the sellers email to the php code and check is it all ready registered or not
  void authenticateRider() async {
    try {
      print(API.validate);
      var res = await http.post(
        Uri.parse(API.validate),
        body: {
          'riders_email': emailController.text.trim(),
        },
      );

      if (res.statusCode ==
          200) //from flutter app the connection with api to server - success
      {
        var resBodyOfValidateEmail = jsonDecode(res.body);
        //if email is not registered it send back response ['emailFound'] ==true
        if (resBodyOfValidateEmail['emailFound'] == true) {
          print("true");
          showDialog(
              context: context,
              builder: (c) {
                return const RidersErrorDialog(
                    message:
                        "Email is already in someone else use. Try another email.");
              });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return const RidersLoadingDialog(
                  message: "Registering Account",
                );
              });
          //if everything is successful then it call uploadImage function
          //start uploading image
          await uploadImage(); // Upload the image

          //resgistering the seller to database my Sql
          registerAndSaveUserRecord();
        }
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  //so this function will save the data in mysql
  registerAndSaveUserRecord() async {
    //here it send the data to the sellers.dart in sellers_madel and change
    //to the json format Go check sellers.dart

    Rider ruserModel = Rider(
      1,
      nameController.text.trim(),
      emailController.text.trim(),
      confirmPasswordController.text.trim(),
      phoneController.text.trim(),
      locationController.text.trim(),
      usersImageUrl,
    );
    try {
      //here the data is sent to the php file
      var res = await http.post(
        //Api is class were its in api_sellers_app/sellers_api_connection.dart
        Uri.parse(API.riderSignUp),
        body: ruserModel.toJson(),
      );
      if (res.statusCode == 200) //from flutter app the connection with api to server - success
      {
        var resBodyOfSignUp = jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(msg: "Registration successful");
          //also get user data from php file as a response
          //its in json format so decode using User class and save data in userInfo variable
          Rider riderInfo = Rider.fromJson(resBodyOfSignUp['userData']);
          //save userInfo to local Storage using Shared Prefrences inside /sellersPreferences/sellers_preferences.dart
          await RememberRiderPrefs.storeRiderInfo(riderInfo);

          //everything go good the user will be sent to SellersHomePage
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => RidersHomeScreen()));
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 10,
            ),
            InkWell(
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
                        size: MediaQuery.of(context).size.width * 0.20,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Email",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: "Password",
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Phone",
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.my_location,
                    controller: locationController,
                    hintText: "Current Location",
                    isObsecre: false,
                    enabled: false,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get my Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        getCurrentLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              onPressed: () {
                //uploadImage();
                formValidation();
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
