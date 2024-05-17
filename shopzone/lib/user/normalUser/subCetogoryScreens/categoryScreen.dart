import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/shopcetogery.dart';
import 'package:http/http.dart' as http;
import 'package:shopzone/user/normalUser/subCetogoryScreens/SubcategoryScreen.dart';

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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(1),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(color: Colors.grey),
                    ),
                    InkWell(
                      onTap: () {
                      // Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => SubCategoryScreen(
                      //             categoryId: model.category_id.toString(),
                      //             categoryName: model.name.toString(),
                      //             categoryImg: model.file_path.toString(),
                      //           ),
                      //         ),
                      //       );
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
         StreamBuilder<List<ShopCategory>>(
           stream: getCategoryStream(),
            builder: (context, AsyncSnapshot<List<ShopCategory>> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (dataSnapshot.hasData &&
                  dataSnapshot.data!.isNotEmpty) {
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 233, 230, 230),
                                    spreadRadius: 0.1,
                                    blurRadius: 5,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 170,
                                    height: 160,
                                    padding: EdgeInsets.all(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                        image: NetworkImage(API.normalImage +
                                            model.file_path.toString()),
                                        fit: BoxFit.cover,
                                      ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                                            Text(
                                  model.name.toString(),
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                                 
                                 
                                ],
                              ),
                            ),
                           
                            
                          ],
                        ),
                      );
                    },
                    childCount: dataSnapshot.data!.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text("No Items Data exists."),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}