import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/noConnectionPage.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/brands.dart'; // Assuming you have a Brands model
import 'package:shopzone/user/normalUser/itemsScreens/items_ui_design_widget.dart';
import 'package:shopzone/user/normalUser/brandsScreens/brands_ui_design_widget.dart'; // Assuming you have a Brands UIDesign widget
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchTerm = "";
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  late Future<Map<String, dynamic>> searchResults;
   List<String> searchHistory = [];

  @override
  void initState() {
    super.initState();
    searchResults = initializeSearching(searchTerm);
  }

  Future<Map<String, dynamic>> initializeSearching(String searchTerm) async {
    final response =
        await http.get(Uri.parse("${API.searchStores}?searchTerm=$searchTerm"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data.');
    }
  }

  Future<Map<String, dynamic>> searchByImage(XFile image) async {
    var request = http.MultipartRequest('POST',
        Uri.parse(API.searchStores)); // Ensure you have an endpoint for this
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(respStr);
      return data;
    } else {
      throw Exception('Failed to load data.');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        searchResults = searchByImage(image);
        Navigator.of(context)
            .pop(); // Close the bottom sheet after selecting an image
      });
    }
  }
  void _addSearchHistory(String term) {
    setState(() {
      if (searchHistory.length == 3) {
        searchHistory.removeAt(0);
      }
      searchHistory.add(term);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 20,
        automaticallyImplyLeading: true,
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              searchTerm = textEntered;
                searchResults = initializeSearching(searchTerm);
            });
          },
              onSubmitted: (textEntered) {
            _addSearchHistory(textEntered);
            setState(() {
              searchTerm = textEntered;
              searchResults = initializeSearching(searchTerm);
            });
          },
          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                     _addSearchHistory(searchTerm);
                    setState(() {
                      searchResults = initializeSearching(searchTerm);
                    });
                  },
                  icon: const Icon(Icons.search),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    _showImageSourceActionSheet(context);
                  },
                  icon: const Icon(Icons.camera_alt),
                  color: Colors.white,
                ),
              ],
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: searchResults,
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: NoConnectionPage());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No record found."));
          } else {
            List<Items> items = (snapshot.data!['items'] as List)
                .map((item) => Items.fromJson(item))
                .toList();
            List<Brands> brands = (snapshot.data!['brands'] as List)
                .map((brand) => Brands.fromJson(brand))
                .toList();

            return Column(
              children: [
                if (_selectedImage != null)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(_selectedImage!.path), height: 600),
                  ),
                    if (searchHistory.isNotEmpty)
                  Column(
                    children: [
                      for (var term in searchHistory)
                        ListTile(
                          leading: Icon(Icons.history),
                          title: Text(term),
                          onTap: () {
                            setState(() {
                              searchTerm = term;
                              searchResults = initializeSearching(searchTerm);
                            });
                          },
                        ),
                    ],
                  ),
                // Horizontal list for brands
                Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      Brands model = brands[index];
                      return BrandsUiDesignWidget(
                        model: model,
                      );
                    },
                  ),
                ),
                // Vertical list for items
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      Items itemsModel = items[index];
                      return ItemsUiDesignWidget(
                        model: itemsModel,
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
