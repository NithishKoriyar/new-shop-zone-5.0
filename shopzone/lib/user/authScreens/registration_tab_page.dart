import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/splashScreen/seller_my_splash_screen.dart';
import 'package:shopzone/user/home/home.dart';
import 'package:shopzone/user/models/user.dart';
import 'package:shopzone/user/userPreferences/user_preferences.dart';
import 'package:shopzone/user/normalUser/widgets/custom_text_field.dart';
import 'package:shopzone/user/normalUser/widgets/loading_dialog.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class RegistrationTabPage extends StatefulWidget {
  const RegistrationTabPage({Key? key}) : super(key: key);

  @override
  _RegistrationTabPageState createState() => _RegistrationTabPageState();
}

class _RegistrationTabPageState extends State<RegistrationTabPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();

  XFile? imageXFile;
  String? imagename;
  String? imagedata;
  File? imagepath;

  final ImagePicker _picker = ImagePicker();
  bool _isRegistering = false;

  String usersImageUrl = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
      String? originalName = imageXFile?.path.split('/').last.split('.').first;
      String? extension = imageXFile?.path.split('.').last;

      String formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      imagename = "${originalName}_$formattedDateTime.$extension";

      imagepath = File(imageXFile!.path);
      imagedata = base64Encode(imagepath!.readAsBytesSync());
    });
  }

  Future<void> uploadImage() async {
    try {
      var res = await http.post(
        Uri.parse(API.profileImage),
        body: {"data": imagedata, "name": imagename},
      );
      var response = jsonDecode(res.body);

      if (response["success"] == true) {
        usersImageUrl = response["path"];
      } else {
        print("Something went wrong");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> formValidation() async {
    if (_isRegistering) return;

    if (imageXFile == null) {
      Fluttertoast.showToast(msg: "Please select an image.");
    } else {
      if (passwordTextEditingController.text == confirmPasswordTextEditingController.text) {
        if (confirmPasswordTextEditingController.text.isNotEmpty &&
            emailTextEditingController.text.isNotEmpty &&
            nameTextEditingController.text.isNotEmpty) {
          setState(() {
            _isRegistering = true;
          });
          authenticateUser();
        } else {
          Fluttertoast.showToast(msg: "Please write the complete required info for Registration.");
        }
      } else {
        Fluttertoast.showToast(msg: "Passwords do not match.");
      }
    }
  }

  void authenticateUser() async {
    try {
      var res = await http.post(
        Uri.parse(API.validateEmail),
        body: {
          'user_email': emailTextEditingController.text.trim(),
        },
      );

      if (res.statusCode == 200) {
        var resBodyOfValidateEmail = jsonDecode(res.body);

        if (resBodyOfValidateEmail['emailFound'] == true) {
          Fluttertoast.showToast(msg: "Email is already in use. Try another email.");
        } else {
          showDialog(
            context: context,
            builder: (c) {
              return LoadingDialogWidget(message: "Registering Account");
            },
          );

          await uploadImage();

          registerAndSaveUserRecord();
        }
      } else {
        print("Failed to register");
      }
    } catch (e) {
      print("Failed to register");
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  void registerAndSaveUserRecord() async {
    User userModel = User(
      1,
      nameTextEditingController.text.trim(),
      emailTextEditingController.text.trim(),
      confirmPasswordTextEditingController.text.trim(),
      usersImageUrl,
      'approved', // Default value for status
    );

    try {
      var res = await http.post(
        Uri.parse(API.register),
        body: userModel.toJson(),
      );
      if (res.statusCode == 200) {
        var resBodyOfSignUp = jsonDecode(res.body);
        if (resBodyOfSignUp['success'] == true) {
          User userInfo = User.fromJson(resBodyOfSignUp['userData']);
          await RememberUserPrefs.storeUserInfo(userInfo);

          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
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
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                _getImage();
              },
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.white,
                backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
                child: imageXFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.20,
                        color: Colors.black,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    textEditingController: nameTextEditingController,
                    iconData: Icons.person,
                    hintText: "Name",
                    isObsecre: false,
                    enabled: true,
                  ),
                  CustomTextField(
                    textEditingController: emailTextEditingController,
                    iconData: Icons.email,
                    hintText: "Email",
                    isObsecre: false,
                    enabled: true,
                  ),
                  CustomTextField(
                    textEditingController: passwordTextEditingController,
                    iconData: Icons.lock,
                    hintText: "Password",
                    isObsecre: true,
                    enabled: true,
                  ),
                  CustomTextField(
                    textEditingController: confirmPasswordTextEditingController,
                    iconData: Icons.lock,
                    hintText: "Confirm Password",
                    isObsecre: true,
                    enabled: true,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const SellerSplashScreen()));
                    },
                    child: const Text(
                      "Are you a Seller? Click Here",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              onPressed: () {
                formValidation();
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}