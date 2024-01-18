import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopzone/rider/ridersPreferences/riders_preferences.dart';
import 'package:shopzone/rider/riders_authentication/riders_auth_screen.dart';
import '../riders_mainScreens/riders_home_screen.dart';


class RidersSplashScreen extends StatefulWidget {
  const RidersSplashScreen({Key? key}) : super(key: key);

  @override
  State<RidersSplashScreen> createState() => _RidersSplashScreenState();
}

class _RidersSplashScreenState extends State<RidersSplashScreen>
{
//the splash screen is there for 3 sec
  startTimer() async
  {
    // Read user info from preferences
   final riderInfo = await RememberRiderPrefs.readRiderInfo();

    Timer(const Duration(seconds: 3), () async
    // if seller is already logged in send theme to homepage or to AuthScreen
    {
        if(riderInfo !=null)
       {
         Navigator.push(context, MaterialPageRoute(builder: (c)=> RidersHomeScreen()));
       }
      //if seller is not loogedin already
    else {
         Navigator.push(
             context, MaterialPageRoute(builder: (c) => const AuthScreen()));
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
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset("images/splash.png"),
              ),

              const SizedBox(height: 10,),

              const Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  "World's Largest Online Food App.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 24,
                    fontFamily: "Signatra",
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}