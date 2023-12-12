import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:shopzone/seller/authScreens/seller_auth_screen.dart';
import 'package:shopzone/seller/brandsScreens/seller_home_screen.dart';
import 'package:shopzone/seller/sellerPreferences/seller_preferences.dart';

import '../sellerPreferences/current_seller.dart';



class SellerSplashScreen extends StatefulWidget {
  const SellerSplashScreen({Key? key}) : super(key: key);

  @override
  State<SellerSplashScreen> createState() => _SellerSplashScreenState();
}

class _SellerSplashScreenState extends State<SellerSplashScreen>
{
//the splash screen is there for 3 sec
  startTimer() async
  {
    // Read user info from preferences
    final sellerInfo = await RememberSellerPrefs.readSellerInfo();

    Timer(const Duration(seconds: 1), () async
    // if seller is already logged in send theme to homepage or to AuthScreen
        {
      if(sellerInfo !=null)
      {
        BindingsBuilder(() {
          Get.put(CurrentSeller()); // Initialize the CurrentSeller instance
        });
        Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
      }
      //if seller is not loogedin already
      else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=> AuthScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        child: Center(
          child: Column(
            //to move image center
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset("images/splash.png"),
              ),
              // to add space between text widget and image
              const SizedBox(
                height: 10,
              ),
              //To display shop name or user name
              const Text(
                "Shop Zone",
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 3,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}