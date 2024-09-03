import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import 'package:http/http.dart' as http;
import 'package:shopzone/api_key.dart';
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
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchRelatedSubCategoriesItems(widget.subcategoryId.toString());
  }

  Future<void> fetchRelatedSubCategoriesItems(String subcategoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${API.fetchRelatedSubCategoriesItems}?subcategoryId=$subcategoryId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          subCategoryItem = data.map((item) => Items.fromJson(item)).toList();
          isLoading = false; // Data is loaded, stop showing shimmer
        });
      } else {
        throw Exception('Failed to load subCategoryItem');
      }
    } catch (e) {
      print('Error fetching subCategoryItem: $e');
      setState(() {
        isLoading = false; // Stop shimmer even if there's an error
      });
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
              isLoading
                  ? buildItemsShimmer() // Show shimmer while loading
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: subCategoryItem.length,
                      itemBuilder: (context, index) {
                        final item = subCategoryItem[index];
                        return Padding(
                          padding: const EdgeInsets.all(0),
                          child: InkWell(
                            onTap: () {
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
                              elevation: 4.0,
                              child: GridTile(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            API.getItemsImage +
                                                (item.thumbnailUrl ?? ''),
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
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
                                          color:
                                              Color.fromARGB(255, 21, 0, 255)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        item.itemInfo ?? 'Unnamed Item',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 82, 82, 82),
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
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemsShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // Number of shimmer items to display
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            color: Colors.amberAccent,
            elevation: 4.0,
            child: GridTile(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
