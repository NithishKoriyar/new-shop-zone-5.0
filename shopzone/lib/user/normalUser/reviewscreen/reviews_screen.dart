import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'dart:convert';

import 'package:shopzone/user/models/review.dart';

class ReviewsScreen extends StatefulWidget {
  final int sellerUID;
  final int userID; // Added user ID at the screen level

  ReviewsScreen({required this.sellerUID, required this.userID});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review> reviews = [];
  int? itemId; // This should be set based on where you get the item ID from

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    var url = Uri.parse('${API.FetchReviews}?seller_id=${widget.sellerUID}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        reviews = jsonResponse.map((data) => Review.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller Reviews"),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reviews[index].reviewText),
            subtitle: Text('Rating: ${reviews[index].rating} Stars'),
            trailing: reviews[index].videoUrl != null ? Icon(Icons.videocam) : null,
            onTap: () {
              if (reviews[index].videoUrl != null) {
                // Play video or navigate to video page
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReviewDialog();
        },
        child: Icon(Icons.add),
        tooltip: 'Add Review',
      ),
    );
  }

  void _showAddReviewDialog() {
    final TextEditingController reviewController = TextEditingController();
    double rating = 3.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Review"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewController,
                decoration: InputDecoration(hintText: "Enter your review here"),
              ),
              Slider(
                min: 1.0,
                max: 5.0,
                divisions: 4,
                value: rating,
                onChanged: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                },
                label: "$rating",
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                postReview(reviewController.text, rating);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void postReview(String reviewText, double rating) async {
    var url = Uri.parse("${API.AddReview}");
    var response = await http.post(url, body: {
      'user_id': '${widget.userID}',
      'seller_id': '${widget.sellerUID}',
      'item_id': itemId.toString(), // Make sure this is set correctly elsewhere
      'rating': rating.toString(),
      'review_text': reviewText,
    });

    if (response.statusCode == 200) {
      fetchReviews(); // Refresh the list after posting
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post review'))
      );
      print('Failed to post review');
    }
  }
}
