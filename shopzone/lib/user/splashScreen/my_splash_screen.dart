import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopzone/user/authScreens/auth_screen.dart';
import 'package:shopzone/user/home/home.dart';
import 'package:shopzone/user/userPreferences/user_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  // the splash screen is there for 3 sec
  startTimer() async {
    // Check for internet connection
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      showNoInternetScreen();
    } else {
      // Internet is available, read user info from preferences
      final userInfo = await RememberUserPrefs.readUserInfo();

      Timer(const Duration(seconds: 3), () {
        // If seller is already logged in send them to homepage, otherwise to AuthScreen
        if (userInfo != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => AuthScreen()));
        }
      });
    }
  }

  void showNoInternetScreen() {
    // Show a dialog or navigate to a "No Internet" screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NoInternetScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset("images/welcome.png"),
            ),
            const SizedBox(height: 10),
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
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset("images/no_internet.png"), // Your "No Internet" image
            ),
            const SizedBox(height: 20),
            const Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Retry the internet connection check
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MySplashScreen()),
                );
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
