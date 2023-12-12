import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import '../splashScreen/seller_my_splash_screen.dart';


class EarningsScreen extends StatefulWidget
{
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}



class _EarningsScreenState extends State<EarningsScreen>
{
  String totalSellerEarnings = "";



Future<void> readTotalEarnings() async {
  final String uid = sellerID;
  final response = await http.get(Uri.parse("${API.earnings}?uid=$uid"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['earnings'] != null) {
      setState(() {
        totalSellerEarnings = data['earnings'].toString();
      });
    } else {
      print("Error fetching earnings: ${data['error']}");
    }
  } else {
    print("Failed to load earnings with status code: ${response.statusCode}");
  }
}

    //!seller information--------------------------------------
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;
  late String sellerImg;

  @override
  void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
       readTotalEarnings();
      // Once the seller info is set, call setState to trigger a rebuild.
      setState(() {});
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
    sellerImg = currentSellerController.seller.seller_profile;
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "₹ " + totalSellerEarnings,
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Total Earnings",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
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

              const SizedBox(height: 40.0,),

              Card(
                color: Colors.white54,
                margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 90),
                child: ListTile(
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=>  SellerSplashScreen()));
                  },
                  leading: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Go Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
