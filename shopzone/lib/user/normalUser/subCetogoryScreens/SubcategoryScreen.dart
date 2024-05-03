import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/subcettogry.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId; // Field for category_id
  final String categoryName; // Field for category_name
  final String categoryImg; // Field for category_img

  // Updated constructor to accept both categoryId and categoryName
  SubCategoryScreen(
      {required this.categoryId,
      required this.categoryName,
      required this.categoryImg});

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late List<Subcategory> subcategories = [];
  @override
  void initState() {
    super.initState();
    fetchSubCategories(widget.categoryId.toString());
  }

  Future<void> fetchSubCategories(categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${API.fetchSubCategories}?id=$categoryId'), // Append the category ID to the URL
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);
        setState(() {
          subcategories =
              data.map((item) => Subcategory.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName), // Use the passed categoryName here
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Image.network(API.normalImage + widget.categoryImg),
              Divider(
                color: Colors.grey, // Choose color of the divider
                height: 20, // The space above and below the divider
                thickness: 2, // Thickness of the divider
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];
                  return ListTile(
                    leading:
                        API.normalImage + subcategory.img_path.toString() !=
                                null
                            ? Image.network(
                                API.normalImage +
                                    subcategory.img_path
                                        .toString(), // Assuming your Subcategory model has an imageUrl field
                                width: 50, // Define the width
                                height: 50, // Define the height
                                fit: BoxFit
                                    .cover, // Cover the entire space of the box
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons
                                      .error); // Error icon if image fails to load
                                },
                              )
                            : null, // If no image URL, nothing is shown
                    title: Text(subcategory.name ?? 'Unnamed Subcategory'),
                    onTap: () {
                      print(API.normalImage + subcategory.img_path.toString());
                      // Define what happens when you tap the ListTile
                    },
                  );
                },
              ),

              // Continue adding other widgets here if needed
            ],
          ),
        ),
      ),
    );
  }
}
