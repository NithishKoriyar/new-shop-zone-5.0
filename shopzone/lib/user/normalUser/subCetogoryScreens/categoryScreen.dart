import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/shopcetogery.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/normalUser/subCetogoryScreens/SubcategoryScreen.dart';
import 'package:shimmer/shimmer.dart';  // Import the shimmer package

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  Stream<List<ShopCategory>> getCategoryStream() async* {
    final response = await http.get(Uri.parse(API.fetchCategories));
    print(API.fetchCategories);

    if (response.statusCode == 200) {
      final categoriesList = json.decode(response.body) as List;
      final categoriesObjects = categoriesList
          .map((item) => ShopCategory.fromJson(item))
          .toList();
      yield categoriesObjects;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: StreamBuilder<List<ShopCategory>>(
        stream: getCategoryStream(),
        builder: (context, AsyncSnapshot<List<ShopCategory>> dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return buildCategoryShimmer(); // Show shimmer effect while loading
          } else if (dataSnapshot.hasData && dataSnapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: dataSnapshot.data!.length,
              itemBuilder: (context, index) {
                ShopCategory model = dataSnapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubCategoryScreen(
                          categoryId: model.category_id.toString(),
                          categoryName: model.name.toString(),
                          categoryImg: model.file_path.toString(),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              API.normalImage + model.file_path.toString(),
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/placeholder.png', // Placeholder image
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              model.name.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text("No Items Data exists."),
            );
          }
        },
      ),
    );
  }

  Widget buildCategoryShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 6, // Number of shimmer items to display
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
