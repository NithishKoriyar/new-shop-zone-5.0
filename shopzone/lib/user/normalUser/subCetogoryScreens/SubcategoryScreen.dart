import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart'; // Import the shimmer package
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/subcettogry.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';
import 'package:shopzone/user/normalUser/subCetogoryScreens/SubcategoryItemsScreen.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String categoryImg;

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
  bool isLoadingSubcategories = true;
  bool isLoadingItems = true;
  String searchQuery = '';

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
          isLoadingSubcategories = false;
        });
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
      setState(() {
        isLoadingSubcategories = false;
      });
    }
  }

  Future<void> fetchRelatedCategoriesItems(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${API.fetchRelatedCategoriesItems}?id=$categoryId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categoryItem = data.map((item) => Items.fromJson(item)).toList();
          isLoadingItems = false;
        });
      } else {
        throw Exception('Failed to load categoryItem');
      }
    } catch (e) {
      print('Error fetching categoryItem: $e');
      setState(() {
        isLoadingItems = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1.0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Subcategories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Subcategories",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    isLoadingSubcategories
                        ? buildSubcategoryShimmer() // Show shimmer while loading subcategories
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: subcategories.length,
                            itemBuilder: (context, index) {
                              final subcategory = subcategories[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SubcategoryItemsScreen(
                                              subcategoryId: subcategory
                                                  .subcategory_id
                                                  .toString()),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8.0),
                                      child: Image.network(
                                        API.normalImage +
                                            subcategory.img_path.toString(),
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      subcategory.name ??
                                          'Unnamed Subcategory',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Items",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    isLoadingItems
                        ? buildItemsShimmer() // Show shimmer while loading items
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: categoryItem.length,
                            itemBuilder: (context, index) {
                              final item = categoryItem[index];
                              return Padding(
                                padding: const EdgeInsets.all(0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ItemsDetailsScreen(
                                                model: item),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0),
                                    ),
                                    elevation: 4.0,
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
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
                                        SizedBox(height: 8),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                          child: Text(
                                            item.itemTitle ??
                                                'Unnamed Item',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          ),
                                        ),
                                        Text(
                                          "₹ ${item.price}",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: Colors.blueAccent),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            item.itemInfo ?? 'Unnamed Item',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
          ),
        ],
      ),
    );
  }

  Widget buildSubcategoryShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // Number of shimmer items to display
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildItemsShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // Number of shimmer items to display
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }
}
