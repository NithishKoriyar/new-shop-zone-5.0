import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';

class SubcategoryItemsScreen extends StatefulWidget {
  final String subcategoryId;

  SubcategoryItemsScreen({required this.subcategoryId});

  @override
  State<SubcategoryItemsScreen> createState() => _SubcategoryItemsScreenState();
}

class _SubcategoryItemsScreenState extends State<SubcategoryItemsScreen> {
  late List<Items> subCategoryItem = [];

  @override
  void initState() {
    super.initState();
    fetchRelatedSubCategoriesItems(widget.subcategoryId.toString());
  }

  Future<void> fetchRelatedSubCategoriesItems(String subcategoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${API.fetchRelatedSubCategoriesItems}?subcategoryId=$subcategoryId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          subCategoryItem = data.map((item) => Items.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load subCategoryItem');
      }
    } catch (e) {
      print('Error fetching subCategoryItem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sub Category Items"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: subCategoryItem.length,
                itemBuilder: (context, index) {
                  final item =
                      subCategoryItem[index]; // Correctly reference the item
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
