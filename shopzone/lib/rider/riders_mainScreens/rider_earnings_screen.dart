import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/ridersPreferences/riders_current_user.dart';
import 'package:shopzone/rider/riders_splashScreen/riders_splash_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  _EarningsScreenState createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final CurrentRider currentRiderController = Get.put(CurrentRider());
  String? riderID;
  String? previousRiderEarnings;

  @override
  void initState() {
    super.initState();
    currentRiderController.getUserInfo().then((_) {
      setRiderInfo();
      setState(() {});
      readTotalEarnings();

      // restrictBlockedRidersFromUsingApp();
    });
  }

  void setRiderInfo() {
    riderID = currentRiderController.rider.riders_id.toString();
  }

  Future<void> readTotalEarnings() async {
  final response = await http.get(Uri.parse("${API.getEarningsRDR}?uid=$riderID"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['earnings'] != null) {
      setState(() {
        
        previousRiderEarnings = data['earnings'].toString();
      });
    } else {
      print("Error fetching earnings: ${data['error']}");
    }
  } else {
    print("Failed to load earnings with status code: ${response.statusCode}");
  }
}


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₹ ${previousRiderEarnings ?? "0"}",
                style: const TextStyle(
                    fontSize: 30, color: Colors.white, fontFamily: "Signatra"),
              ),
              const Text(
                "Total Earnings",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: Colors.white,
                  thickness: 1.5,
                ),
              ),
              const SizedBox(
                height: 40.0,
              ),
              GestureDetector(
                onTap: () {
                 Navigator.pop(context);
                },
                child: const Card(
                  color: Colors.white54,
                  margin: EdgeInsets.symmetric(vertical: 40, horizontal: 110),
                  child: ListTile(
                    
                    
                   
                    leading: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      
                    ),
                    title: Text(
                      "Go Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
