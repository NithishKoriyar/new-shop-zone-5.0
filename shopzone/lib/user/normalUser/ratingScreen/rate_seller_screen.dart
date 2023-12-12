import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/global/global.dart';
import 'package:shopzone/user/models/orders.dart';
import 'package:shopzone/user/splashScreen/my_splash_screen.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

// ignore: must_be_immutable
class RateSellerScreen extends StatefulWidget {
  Orders? model;

  RateSellerScreen({super.key, 
     this.model,
  });

  @override
  State<RateSellerScreen> createState() => _RateSellerScreenState();
}

class _RateSellerScreenState extends State<RateSellerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        backgroundColor: Colors.white60,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22,
              ),
              const Text(
                "Rate this Seller",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 22,
              ),
              const Divider(
                height: 4,
                thickness: 4,
              ),
              const SizedBox(
                height: 22,
              ),
              SmoothStarRating(
                rating: countStarsRating,
                allowHalfRating: true,
                starCount: 5,
                color: Colors.purpleAccent,
                borderColor: Colors.purpleAccent,
                size: 46,
                onRatingChanged: (valueOfStarsChoosed) {
                  countStarsRating = valueOfStarsChoosed;

                  if (countStarsRating == 1) {
                    setState(() {
                      titleStarsRating = "Very Bad";
                    });
                  }
                  if (countStarsRating == 2) {
                    setState(() {
                      titleStarsRating = "Bad";
                    });
                  }
                  if (countStarsRating == 3) {
                    setState(() {
                      titleStarsRating = "Good";
                    });
                  }
                  if (countStarsRating == 4) {
                    setState(() {
                      titleStarsRating = "Very Good";
                    });
                  }
                  if (countStarsRating == 5) {
                    setState(() {
                      titleStarsRating = "Excellent";
                    });
                  }
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                titleStarsRating,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              ElevatedButton(
                onPressed: () async {
                  //!getSellerRating
                  final response = await http.post(
                      Uri.parse(API.getSellerRating),
                      body: {'sellerId': widget.model?.sellerUID});

                  final data = jsonDecode(response.body);

                  if (data['rating'] == null) {
                    await http.post(
                        //!updateSellerRating
                        Uri.parse(API.updateSellerRating),
                        body: {
                          'sellerId': widget.model?.sellerUID,
                          'rating': countStarsRating.toString()
                        });
                  } else {
                    double pastRatings =
                        double.parse(data['rating'].toString());
                    double newRatings = (pastRatings + countStarsRating) / 2;

                    await http.post(
                        Uri.parse(API.updateSellerRating),
                        body: {
                          'sellerId': widget.model?.sellerUID,
                          'rating': newRatings.toString()
                        });
                  }

                  Fluttertoast.showToast(msg: "Rated Successfully.");

                  setState(() {
                    countStarsRating = 0.0;
                    titleStarsRating = "";
                  });

                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => MySplashScreen()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 74),
                ),
                child: const Text("Submit"),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
