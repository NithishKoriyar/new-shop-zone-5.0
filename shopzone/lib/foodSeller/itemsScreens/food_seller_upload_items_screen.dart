import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/foodSeller/brandsScreens/food_seller_home_screen.dart';
import 'package:shopzone/foodSeller/foodSellerPreferences/food_current_seller.dart';
import 'package:shopzone/foodSeller/models/food_seller_brands.dart';
import 'package:shopzone/foodSeller/splashScreen/food_seller_my_splash_screen.dart';
import 'package:shopzone/foodSeller/widgets/food_seller_progress_bar.dart';

// ignore: must_be_immutable
class UploadItemsScreen extends StatefulWidget {
  Brands? model;

  UploadItemsScreen({
    this.model,
  });

  @override
  State<UploadItemsScreen> createState() => _UploadItemsScreenState();
}

class _UploadItemsScreenState extends State<UploadItemsScreen> {
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();

  TextEditingController itemInfoTextEditingController = TextEditingController();
  TextEditingController itemTitleTextEditingController =
      TextEditingController();
  TextEditingController itemDescriptionTextEditingController =
      TextEditingController();
  TextEditingController itemPriceTextEditingController =
      TextEditingController();

  bool uploading = false;
  String itemUniqueId = DateTime.now().millisecondsSinceEpoch.toString();

Future<void> validateUploadForm() async {
    if (imgXFile != null) {
      if (itemInfoTextEditingController.text.isNotEmpty &&
          itemTitleTextEditingController.text.isNotEmpty &&
          itemDescriptionTextEditingController.text.isNotEmpty &&
          itemPriceTextEditingController.text.isNotEmpty) {
        
        var imageBytes = await imgXFile!.readAsBytes();
        var base64Image = base64Encode(imageBytes);

        var body = {
          'itemInfo': itemInfoTextEditingController.text.trim(),
          'itemTitle': itemTitleTextEditingController.text.trim(),
          'itemID': itemUniqueId,
          'itemDescription': itemDescriptionTextEditingController.text.trim(),
          'itemPrice': itemPriceTextEditingController.text.trim(),
          'brandID': widget.model!.brandID.toString(),
          'sellerUID': sellerID,
          'sellerName': sellerName,
          'image': base64Image,
        };

        var response = await http.post(
          Uri.parse(API.foodSellerUploadItem),
          body: json.encode(body),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          var responseJson = json.decode(response.body);

          if (responseJson['success']) {
            Fluttertoast.showToast(msg: responseJson['message']);
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => HomeScreen()));
          } else {
            Fluttertoast.showToast(msg: "Error: " + responseJson['message']);
          }
        } else {
          Fluttertoast.showToast(msg: "Network error: Unable to upload.");
        }
      } else {
        Fluttertoast.showToast(msg: "Please fill complete form.");
      }
    } else {
      Fluttertoast.showToast(msg: "Please choose an image.");
    }
}

  uploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => FoodSellerSplashScreen()));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: () {
                //validate upload form
                uploading == true ? null : validateUploadForm();
              },
              icon: const Icon(
                Icons.cloud_upload,
              ),
            ),
          ),
        ],
elevation: 20,
        title: const Text("Upload New Item"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          uploading == true ? linearProgressBar() : Container(),

          //image
          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                        File(
                          imgXFile!.path,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.black,
            thickness: 1,
          ),

          //brand info
          ListTile(
            leading: const Icon(
              Icons.perm_device_information,
              color: Colors.black,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: itemInfoTextEditingController,
                decoration: const InputDecoration(
                  hintText: "item info",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),

          //brand title
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.black,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: itemTitleTextEditingController,
                decoration: const InputDecoration(
                  hintText: "item title",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),

          //item description
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.black,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: itemDescriptionTextEditingController,
                decoration: const InputDecoration(
                  hintText: "item description",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),

          //item price
          ListTile(
            leading: const Icon(
              Icons.currency_rupee,
              color: Colors.black,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: itemPriceTextEditingController,
                decoration: const InputDecoration(
                  hintText: "item price",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  //!--------------------------------
  final CurrentFoodSeller currentSellerController = Get.put(CurrentFoodSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;
  late String sellerImg;

  @override
  void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
      printSellerInfo();
    });
  }

  void setSellerInfo() {
    sellerName = currentSellerController.seller.seller_name;
    sellerEmail = currentSellerController.seller.seller_email;
    sellerID = currentSellerController.seller.seller_id.toString();
  }

  void printSellerInfo() {
    print("-------items Screens-------");
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller Email: $sellerID');
  }

  //!seller information--------------------------------------
  Widget build(BuildContext context) {
    return imgXFile == null ? defaultScreen() : uploadFormScreen();
  }

  defaultScreen() {
    return Scaffold(
      appBar: AppBar(
elevation: 20,
        title: const Text("Add New Item"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white,
          ],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        )),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate,
                color: Colors.black,
                size: 200,
              ),
              ElevatedButton(
                  onPressed: () {
                    obtainImageDialogBox();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Add New Item",
                  )),
            ],
          ),
        ),
      ),
    );
  }

  obtainImageDialogBox() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Center(
              child: Text(
                "Brand Image",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  captureImagewithPhoneCamera();
                },
                child: const Center(
                  child: Text(
                    "Capture image with Camera",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  getImageFromGallery();
                },
                child: const Center(
                  child: Text(
                    "Select image from Gallery",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (c) => HomeScreen()));
                },
                child: const Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<XFile?> compressImage(XFile? file, {bool compress = true}) async {
    if (file == null) return null;

    if (!compress) {
      return file;
    }

    final filePath = file.path;
    final fileName = filePath.split('/').last;
    final targetPath = Directory.systemTemp.path + "/$fileName";

    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 88, // Adjust the quality as needed
      minWidth: 800, // Adjust the width as needed
      minHeight: 600, // Adjust the height as needed
    );

    return result != null ? XFile(result.path) : null;
  }

  getImageFromGallery() async {
    Navigator.pop(context);
    var originalImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    imgXFile = await compressImage(originalImage, compress: false);
    setState(() {});
  }

  captureImagewithPhoneCamera() async {
    Navigator.pop(context);
    var originalImage = await imagePicker.pickImage(source: ImageSource.camera);
    imgXFile = await compressImage(originalImage);
    setState(() {});
  }
}
