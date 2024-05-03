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

  Future<void> fetchSubCategories(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${API.fetchSubCategories}?id=$categoryId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Image.network(API.normalImage + widget.categoryImg),
              Divider(
                color: Colors.grey,
                height: 20,
                thickness: 2,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Adjust number of columns
                  childAspectRatio: 1, // Adjust the aspect ratio
                  crossAxisSpacing: 10, // Horizontal space between items
                  mainAxisSpacing: 10, // Vertical space between items
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];
                  return GridTile(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.network(
                            API.normalImage + subcategory.img_path.toString(),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error),
                          ),
                        ),
                        SizedBox(height: 8), // Spacing between image and text
                        Text(subcategory.name ?? 'Unnamed Subcategory',
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
