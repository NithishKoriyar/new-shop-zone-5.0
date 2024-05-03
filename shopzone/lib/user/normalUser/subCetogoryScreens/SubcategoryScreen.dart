import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/subcettogry.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_screen.dart';
import 'package:shopzone/user/normalUser/subCetogoryScreens/SubcategoryItemsScreen.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId; // Field for category_id
  final String categoryName; // Field for category_name
  final String categoryImg; // Field for category_img

  // Updated constructor to accept both categoryId and categoryName
  SubCategoryScreen({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImg,
  });

  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late List<Subcategory> subcategories = [];
  late List<Items> categoryItem = [];

  @override
  void initState() {
    super.initState();
    fetchSubCategories(widget.categoryId.toString());
    fetchRelatedCategoriesItems(widget.categoryId.toString());
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

  Future<void> fetchRelatedCategoriesItems(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${API.fetchRelatedCategoriesItems}?id=$categoryId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);

        setState(() {
          categoryItem = data.map((item) => Items.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load categoryItem');
      }
    } catch (e) {
      print('Error fetching categoryItem: $e');
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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Image.network(API.normalImage + widget.categoryImg),
              const Divider(
                color: Colors.grey,
                height: 20,
                thickness: 2,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust number of columns
                  childAspectRatio: 1, // Adjust the aspect ratio
                  crossAxisSpacing: 10, // Horizontal space between items
                  mainAxisSpacing: 10, // Vertical space between items
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = subcategories[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubcategoryItemsScreen(
                              subcategoryId:
                                  subcategory.subcategory_id.toString()),
                        ),
                      );
                    },
                    child: GridTile(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                API.normalImage +
                                    subcategory.img_path.toString(),
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 8), // Spacing between image and text
                          Text(subcategory.name ?? 'Unnamed Subcategory',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("I T M S"),
              const SizedBox(
                height: 20,
              ),
              //!================================================================================================================================
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categoryItem.length,
                itemBuilder: (context, index) {
                  final item =
                      categoryItem[index]; // Correctly reference the item
                  return Padding(
                    padding:
                        const EdgeInsets.all(0), // Adjust padding as needed
                    child: InkWell(
                      onTap: () {
                        // Navigate to the ItemsDetailsScreen and pass the selected item model
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemsDetailsScreen(model: item),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.amberAccent,
                        elevation: 4.0, // Adjust elevation as needed
                        child: GridTile(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      8.0), // Adjust padding as needed
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Set the border radius as needed
                                    child: Image.network(
                                      API.getItemsImage +
                                          (item.thumbnailUrl ??
                                              ''), // Correctly handle possible null
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.itemTitle ?? 'Unnamed Item',
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                "₹ ${item.price}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 21, 0, 255)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  item.itemInfo ?? 'Unnamed Item',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 82, 82, 82),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
