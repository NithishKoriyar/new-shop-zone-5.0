import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import 'package:shopzone/seller/splashScreen/seller_my_splash_screen.dart';
import 'package:shopzone/seller/widgets/seller_progress_bar.dart';

class SimilarProductScreen extends StatefulWidget {
  final String itemId; // Pass the original item ID to use as variant ID
  final String brandId; // Pass the brand ID to use as variant ID
  final String variantID; // Pass the variant ID to use as variant ID
  final String category_id;
  final String sub_category_id;

  SimilarProductScreen(
      {required this.itemId,
      required this.brandId,
      required this.variantID,
      required this.category_id,
      required this.sub_category_id});

  @override
  _SimilarProductScreenState createState() => _SimilarProductScreenState();
}

class _SimilarProductScreenState extends State<SimilarProductScreen> {
  final ImagePicker imagePicker = ImagePicker();
  List<String> selectedSizeName = [];
  List<String> selectedColorName = [];
  List sizes = [];
  List colors = [];

  TextEditingController itemInfoTextEditingController = TextEditingController();
  TextEditingController itemTitleTextEditingController =
      TextEditingController();
  TextEditingController itemDescriptionTextEditingController =
      TextEditingController();
  TextEditingController itemPriceTextEditingController =
      TextEditingController();

  bool uploading = false;
  String itemUniqueId = DateTime.now().millisecondsSinceEpoch.toString();

  XFile? thumbnail;
  XFile? secondImage;
  XFile? thirdImage;
  XFile? fourthImage;
  XFile? fifthImage;

  Future<void> validateUploadForm() async {
    if (thumbnail != null &&
        secondImage != null &&
        thirdImage != null &&
        fourthImage != null &&
        fifthImage != null) {
      if (itemInfoTextEditingController.text.isNotEmpty &&
          itemTitleTextEditingController.text.isNotEmpty &&
          itemDescriptionTextEditingController.text.isNotEmpty &&
          itemPriceTextEditingController.text.isNotEmpty &&
          selectedSizeName.isNotEmpty &&
          selectedColorName.isNotEmpty) {
        var thumbnailBytes = await thumbnail!.readAsBytes();
        var secondImageBytes = await secondImage!.readAsBytes();
        var thirdImageBytes = await thirdImage!.readAsBytes();
        var fourthImageBytes = await fourthImage!.readAsBytes();
        var fifthImageBytes = await fifthImage!.readAsBytes();

        var body = {
          'itemInfo': itemInfoTextEditingController.text.trim(),
          'itemTitle': itemTitleTextEditingController.text.trim(),
          'itemID': itemUniqueId,
          'variantID': widget.variantID, // Use original item ID as variant ID
          'itemDescription': itemDescriptionTextEditingController.text.trim(),
          'itemPrice': itemPriceTextEditingController.text.trim(),
          'brandID': widget.brandId, // Replace with actual brand ID
          'sellerUID': sellerID,
          'sellerName': sellerName,
          'thumbnail': base64Encode(thumbnailBytes),
          'secondImage': base64Encode(secondImageBytes),
          'thirdImage': base64Encode(thirdImageBytes),
          'fourthImage': base64Encode(fourthImageBytes),
          'fifthImage': base64Encode(fifthImageBytes),
          'category_id': widget.category_id,
          'sub_category_id': widget.sub_category_id,
          'SizeName': selectedSizeName.join(','),
          'ColourName': selectedColorName.join(','),
        };

        var response = await http.post(
          Uri.parse(API.uploadSimilarItem), // Update with your API endpoint
          body: json.encode(body),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          var responseJson = json.decode(response.body);

          if (responseJson['success']) {
            Fluttertoast.showToast(msg: responseJson['message']);
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => SellerSplashScreen()));
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
      Fluttertoast.showToast(msg: "Please choose all images.");
    }
  }

  final CurrentSeller currentSellerController = Get.put(CurrentSeller());

  late String sellerName;
  late String sellerEmail;
  late String sellerID;

  @override
  void initState() {
    super.initState();
    currentSellerController.getSellerInfo().then((_) {
      setSellerInfo();
      printSellerInfo();
    });
    fetchSizesAndColors(widget.sub_category_id);
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
    print('Seller ID: $sellerID');
  }

  Future<void> fetchSizesAndColors(String subCategoryId) async {
    var sizeUrl = Uri.parse('${API.fetchSizes}?subCategoryId=$subCategoryId');
    var colorUrl = Uri.parse('${API.fetchColors}?subCategoryId=$subCategoryId');

    var sizeResponse = await http.get(sizeUrl);
    var colorResponse = await http.get(colorUrl);

    if (sizeResponse.statusCode == 200 && colorResponse.statusCode == 200) {
      var sizeData = json.decode(sizeResponse.body) as List;
      var colorData = json.decode(colorResponse.body) as List;

      setState(() {
        sizes = sizeData;
        colors = colorData;
      });
    } else {
      print('Failed to load sizes and colors');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => SellerSplashScreen()));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: () {
                uploading == true ? null : validateUploadForm();
              },
              icon: const Icon(Icons.cloud_upload),
            ),
          ),
        ],
        elevation: 20,
        title: const Text("Upload Similar Product"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          uploading ? LinearProgressIndicator() : Container(),
          imagePreview(thumbnail, "Main Image", () => pickImage('main')),
          imagePreview(secondImage, "Second Image", () => pickImage('second')),
          imagePreview(thirdImage, "Third Image", () => pickImage('third')),
          imagePreview(fourthImage, "Fourth Image", () => pickImage('fourth')),
          imagePreview(fifthImage, "Fifth Image", () => pickImage('fifth')),
          const Divider(color: Colors.black, thickness: 1),
          ListTile(
            leading: const Icon(Icons.title, color: Colors.black),
            title: TextField(
              controller: itemTitleTextEditingController,
              decoration: const InputDecoration(
                  hintText: "item title", border: InputBorder.none),
            ),
          ),
          const Divider(color: Colors.black, thickness: 1),
          ListTile(
            leading:
                const Icon(Icons.perm_device_information, color: Colors.black),
            title: TextField(
              controller: itemInfoTextEditingController,
              decoration: const InputDecoration(
                  hintText: "item info", border: InputBorder.none),
            ),
          ),
          const Divider(color: Colors.black, thickness: 1),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.black),
            title: TextField(
              controller: itemDescriptionTextEditingController,
              decoration: const InputDecoration(
                  hintText: "item description", border: InputBorder.none),
            ),
          ),
          const Divider(color: Colors.black, thickness: 1),
          ListTile(
            leading: const Icon(Icons.currency_rupee, color: Colors.black),
            title: TextField(
              controller: itemPriceTextEditingController,
              decoration: const InputDecoration(
                  hintText: "item price", border: InputBorder.none),
            ),
          ),
          const Divider(color: Colors.black, thickness: 1),
          if (sizes.isNotEmpty)
            MultiSelectDialogField(
              items: sizes
                  .map((size) => MultiSelectItem<String>(
                      size['SizeName'], size['SizeName']))
                  .toList(),
              title: const Text("Select Size"),
              selectedColor: Colors.black,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                border: Border.all(color: Colors.black, width: 2),
              ),
              buttonIcon:
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
              buttonText: const Text("Select Size",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
              onConfirm: (results) {
                setState(() {
                  selectedSizeName = results.cast<String>();
                });
              },
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) {
                  setState(() {
                    selectedSizeName.remove(value);
                  });
                },
              ),
            ),
          const Divider(color: Colors.black, thickness: 1),
          if (colors.isNotEmpty)
            MultiSelectDialogField(
              items: colors
                  .map((color) => MultiSelectItem<String>(
                      color['ColourName'], color['ColourName']))
                  .toList(),
              title: const Text("Select Color"),
              selectedColor: Colors.black,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                border: Border.all(color: Colors.black, width: 2),
              ),
              buttonIcon:
                  const Icon(Icons.arrow_drop_down, color: Colors.black),
              buttonText: const Text("Select Color",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
              onConfirm: (results) {
                setState(() {
                  selectedColorName = results.cast<String>();
                });
              },
              chipDisplay: MultiSelectChipDisplay(
                onTap: (value) {
                  setState(() {
                    selectedColorName.remove(value);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<XFile?> compressImage(XFile? file, {bool compress = true}) async {
    if (file == null) return null;

    if (!compress) {
      return file;
    }

    final filePath = file.path;
    final fileName = filePath.split('/').last;
    final fileFormat = fileName.split('.').last;
    CompressFormat format;
    switch (fileFormat) {
      case 'jpeg':
        format = CompressFormat.jpeg;
        break;
      case 'png':
        format = CompressFormat.png;
        break;
      case 'webp':
        format = CompressFormat.webp;
        break;
      default:
        format = CompressFormat.jpeg;
    }
    final targetPath = Directory.systemTemp.path + "/$fileName";

    var result =
        await FlutterImageCompress.compressAndGetFile(filePath, targetPath,
            quality: 88, // Adjust the quality as needed
            minWidth: 800, // Adjust the width as needed
            minHeight: 600, // Adjust the height as needed
            format: format);

    return result != null ? XFile(result.path) : null;
  }

  pickImage(String imageType) async {
    var originalImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    var compressedImage = await compressImage(originalImage);

    setState(() {
      switch (imageType) {
        case 'main':
          thumbnail = compressedImage;
          break;
        case 'second':
          secondImage = compressedImage;
          break;
        case 'third':
          thirdImage = compressedImage;
          break;
        case 'fourth':
          fourthImage = compressedImage;
          break;
        case 'fifth':
          fifthImage = compressedImage;
          break;
      }
    });
  }

  Widget imagePreview(XFile? image, String label, VoidCallback onPressed) {
    return Column(
      children: [
        Text(label),
        image == null
            ? IconButton(
                icon: Icon(Icons.add_photo_alternate),
                onPressed: onPressed,
              )
            : Image.file(
                File(image.path),
                height: 150,
                width: 150,
              ),
        const Divider(color: Colors.black, thickness: 1),
      ],
    );
  }
}
