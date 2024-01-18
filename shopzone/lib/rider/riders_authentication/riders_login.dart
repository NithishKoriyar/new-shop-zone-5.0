import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_mainScreens/riders_home_screen.dart';
import 'package:shopzone/rider/riders_widgets/riders_error_dialog.dart';
import '../ridersPreferences/riders_preferences.dart';
import '../riders_model/riders_user.dart';
import '../riders_widgets/riders_custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController =  TextEditingController();
  TextEditingController passwordController =  TextEditingController();



  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    }
    else {
      showDialog(
          context: context,
          builder: (c)
          {
            return const RidersErrorDialog(
              message: "Please write email/password.",
            );
          }
      );
    }
  }
   loginNow() async
   {
     try
     {
      print(API.riderLogin);
       var res = await http.post(
         Uri.parse(API.riderLogin),
         
         body: {
           "riders_email": emailController.text.trim(),
           "riders_password": passwordController.text.trim(),
         },
       );

       if(res.statusCode == 200) //from flutter app the connection with api to server - success
           {
         var resBodyOfLogin = jsonDecode(res.body);

         print("---------------------------${resBodyOfLogin}");



         if (resBodyOfLogin['success'] == true) {
           Fluttertoast.showToast(msg: "you are logged-in Successfully.");


           Rider ruserInfo = Rider.fromJson(resBodyOfLogin['userData']);

           //save userInfo to local Storage using Shared Prefrences
           await RememberRiderPrefs.storeRiderInfo(ruserInfo);

           Navigator.pop(context);
           Navigator.push(context, MaterialPageRoute(builder: (c)=>RidersHomeScreen()));
         } else {
           Fluttertoast.showToast(msg: "Incorrect Credentials.\nPlease write correct password or email and Try Again.");
         }
       }
       else
       {
         Fluttertoast.showToast(msg: "Status is not 200");
       }
     }
     catch(errorMsg)
     {
       print("Error :: " + errorMsg.toString());
     }
   }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(
                "images/signup.png",
                height: 270,
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
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
              ],
            ),
          ),
          const SizedBox(height: 30,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding:const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            ),
            onPressed: (){
              formValidation();
            },
            child: const Text(
              "Log In",
              style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold,),
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }
}
