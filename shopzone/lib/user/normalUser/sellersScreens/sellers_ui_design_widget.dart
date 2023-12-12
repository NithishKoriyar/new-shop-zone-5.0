import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/sellers.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import '../brandsScreens/brands_screen.dart';

// ignore: must_be_immutable
class SellersUIDesignWidget extends StatefulWidget {
  Sellers? model;

  SellersUIDesignWidget({
    this.model,
  });

  @override
  State<SellersUIDesignWidget> createState() => _SellersUIDesignWidgetState();
}

class _SellersUIDesignWidgetState extends State<SellersUIDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         print("Rating...");
        print(widget.model!.rating);
        //send user to a seller's brands screen
        Navigator.push(context, MaterialPageRoute(builder: (c)=> BrandsScreen(
          model: widget.model,
        )));
      },
      child: Card(
        color: Colors.white,
        elevation: 20,
        shadowColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 270,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    Uri.parse(API.sellerImage + widget.model!.sellerProfile).toString(),
                    height: 220,
                    fit: BoxFit.fill,
                  ),
                ),

                const SizedBox(
                  height: 1,
                ),
                Text(
                  widget.model!.sellerName.toString(),
                  style: const TextStyle(
                    color: Colors.pinkAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SmoothStarRating(
                  // ignore: unnecessary_null_comparison
                  rating: widget.model!.rating == null
                      ? 0.0
                      : double.parse(widget.model!.rating.toString()),
                  starCount: 5,
                  color: Colors.pinkAccent,
                  borderColor: Colors.pinkAccent,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
