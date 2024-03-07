import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/brandsScreens/seller_home_screen.dart';
import 'package:shopzone/seller/models/seller.dart';
import 'package:shopzone/seller/sellerPreferences/seller_preferences.dart';
import 'package:shopzone/seller/widgets/seller_custom_text_field.dart';
import 'package:shopzone/seller/widgets/seller_loading_dialog.dart';

class LoginTabPage extends StatefulWidget {
  @override
  State<LoginTabPage> createState() => _LoginTabPageState();
}

class _LoginTabPageState extends State<LoginTabPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  validateForm() {
    if (emailTextEditingController.text.isNotEmpty &&
        passwordTextEditingController.text.isNotEmpty) {
      // Allow user to login
      loginNow();
    } else {
      Fluttertoast.showToast(msg: "Please provide email and password.");
    }
  }

  loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialogWidget(
          message: "Checking credentials",
        );
      },
    );
    try {
      var res = await http.post(
        Uri.parse(API.loginSeller),
        body: {
          "seller_email": emailTextEditingController.text.trim(),
          "seller_password": passwordTextEditingController.text.trim(),
        },
      );
      final String email = emailTextEditingController.text.trim();
      final String password = passwordTextEditingController.text.trim();

      print(
          "Login request - Email: $email, Password: $password"); // Print the email and password

      if (res.statusCode ==
          200) //from flutter app the connection with api to server - success
      {
        print("--------------------------------");
        print(res.body);
        var resBodyOfLogin = jsonDecode(res.body);
        print("--------------------------------");
        print(resBodyOfLogin);
        if (resBodyOfLogin['success'] == true) {
          Fluttertoast.showToast(msg: "you are logged-in Successfully.");

          Seller sellerInfo = Seller.fromJson(resBodyOfLogin["sellerData"]);

          //save sellerInfo to local Storage using Shared Prefrences
          await RememberSellerPrefs.storeSellerInfo(sellerInfo);

          Future.delayed(Duration(milliseconds: 2000), () {
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => HomeScreen()));
          });
        } else {
          Fluttertoast.showToast(
              msg:
                  "Incorrect Credentials.\nPlease write correct password or email and Try Again.");
        }
      } else {
        Fluttertoast.showToast(msg: "Status is not 200");
      }
    } catch (errorMsg) {
      print("Error :: " + errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "images/seller.png",
              height: MediaQuery.of(context).size.height * 0.40,
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                //email
                CustomTextField(
                  textEditingController: emailTextEditingController,
                  iconData: Icons.email,
                  hintText: "Email",
                  isObsecre: false,
                  enabled: true,
                  keyboardType: TextInputType.emailAddress,
                ),

                //pass
                CustomTextField(
                  textEditingController: passwordTextEditingController,
                  iconData: Icons.lock,
                  hintText: "Password",
                  isObsecre: true,
                  enabled: true,
                  keyboardType: TextInputType.streetAddress,
                ),

                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              onPressed: () {
                validateForm();
              },
              child: const Text(
                "Login",
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
    );
  }
}
