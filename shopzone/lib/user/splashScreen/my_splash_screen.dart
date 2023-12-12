import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopzone/user/authScreens/auth_screen.dart';
import 'package:shopzone/user/home/home.dart';
import 'package:shopzone/user/userPreferences/user_preferences.dart';



class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{
//the splash screen is there for 3 sec
  startTimer() async
  {
    // Read user info from preferences
    final userInfo = await RememberUserPrefs.readUserInfo();

    Timer(const Duration(seconds: 1), () async
    // if seller is already logged in send theme to homepage or to AuthScreen
        {
      if(userInfo !=null)
      {
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
                child: Image.asset("images/welcome.png"),
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