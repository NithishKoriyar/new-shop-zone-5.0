import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/noConnectionPage.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/models/brands.dart'; // Assuming you have a Brands model
import 'package:shopzone/user/normalUser/itemsScreens/items_ui_design_widget.dart';
import 'package:shopzone/user/normalUser/brandsScreens/brands_ui_design_widget.dart'; // Assuming you have a Brands UIDesign widget
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shopzone/user/normalUser/searchScreen/searchitem_ui_design_widget.dart';
import 'package:shimmer/shimmer.dart';

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
  List<Items> searchItems = [];
  List<Brands> searchBrands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    searchResults = initializeSearching(searchTerm);
  }

  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', searchHistory);
  }

  Future<Map<String, dynamic>> initializeSearching(String searchTerm) async {
    setState(() {
      _isLoading = true;
    });
    
    final response =
        await http.get(Uri.parse("${API.searchStores}?searchTerm=$searchTerm"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        searchItems = (data['items'] as List)
            .map((item) => Items.fromJson(item))
            .toList();
        searchBrands = (data['brands'] as List)
            .map((brand) => Brands.fromJson(brand))
            .toList();
        _isLoading = false;
      });
      return data;
    } else {
      throw Exception('Failed to load data.');
    }
  }

  Future<Map<String, dynamic>> searchByImage(XFile image) async {
    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest('POST',
        Uri.parse(API.searchStores)); // Ensure you have an endpoint for this
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(respStr);
      setState(() {
        searchItems = (data['items'] as List)
            .map((item) => Items.fromJson(item))
            .toList();
        searchBrands = (data['brands'] as List)
            .map((brand) => Brands.fromJson(brand))
            .toList();
        _isLoading = false;
      });
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
      if (!searchHistory.contains(term)) {
        searchHistory.add(term);
      }
      _saveSearchHistory();
    });
  }

  void _onSearchAgain() {
    setState(() {
      searchResults = initializeSearching(searchTerm);
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
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(child: NoConnectionPage());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/no_results.png', // Your image asset path
                    height: 150.0,
                    width: 150.0,
                  ), // Ensure you have this image in your assets
                  SizedBox(height: 20),
                  Text(
                    "Sorry, no results found!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please check the spelling or try searching for something else",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onSearchAgain,
                    child: Text("Search Again"),
                  ),
                ],
              ),
            );
          } else {
            List<Items> items = (snapshot.data!['items'] as List)
                .map((item) => Items.fromJson(item))
                .toList();
            List<Brands> brands = (snapshot.data!['brands'] as List)
                .map((brand) => Brands.fromJson(brand))
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImage != null)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Image.file(File(_selectedImage!.path), height: 600),
                    ),
                  if (searchHistory.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                  if (items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Searched Items",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio:
                          0.75, // Adjust the aspect ratio as needed
                    ),
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      Items itemsModel = items[index];
                      return SearchItemsUiDesignWidget(
                        model: itemsModel,
                      );
                    },
                  ),
                  if (brands.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Popular Products",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 columns
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio:
                          0.75, // Adjust the aspect ratio as needed
                    ),
                    itemCount: brands.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      Brands brandsModel = brands[index];
                      return BrandsUiDesignWidget(
                        model: brandsModel,
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Container(
                    height: 150,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Loading Items...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 columns
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.75, // Adjust the aspect ratio as needed
            ),
            itemCount: 6, // Show 6 shimmer items as placeholders
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
