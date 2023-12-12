import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopzone/seller/brandsScreens/seller_home_screen.dart';
import 'package:shopzone/seller/sellerPreferences/current_seller.dart';
import 'package:shopzone/seller/splashScreen/seller_my_splash_screen.dart';
import '../../api_key.dart';
import '../widgets/seller_progress_bar.dart';
import 'package:http/http.dart' as http;

class UploadBrandsScreen extends StatefulWidget {
  @override
  _UploadBrandsScreenState createState() => _UploadBrandsScreenState();
}

class _UploadBrandsScreenState extends State<UploadBrandsScreen> {
  final CurrentSeller currentSellerController = Get.put(CurrentSeller());
  late String sellerName, sellerEmail, sellerID;
  XFile? imgXFile;
  final ImagePicker imagePicker = ImagePicker();
  TextEditingController brandInfoTextEditingController =
      TextEditingController();
  TextEditingController brandTitleTextEditingController =
      TextEditingController();
  bool uploading = false;
  String brandID = DateTime.now().millisecondsSinceEpoch.toString();

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
    print('Seller Name: $sellerName');
    print('Seller Email: $sellerEmail');
    print('Seller Email: $sellerID');
  }

  validateUploadForm() async {
    if (imgXFile != null) {
      if (brandInfoTextEditingController.text.isNotEmpty &&
          brandTitleTextEditingController.text.isNotEmpty) {
        setState(() {
          uploading = true;
        });

        // Step 1: Upload the image
final bytes = await imgXFile!.readAsBytes();
final imgBase64 = base64Encode(bytes);

final response = await http.post(
  Uri.parse(API.saveBrandImage),
  body: {
    'thumbnailUrl': imgBase64,
  },
);

final imgResponseBody = response.body;

        if (response.statusCode == 200) {
          try {
            var imgJsonResponse = jsonDecode(imgResponseBody);
            if (imgJsonResponse['status'] == 'success') {
              String imageUrl = imgJsonResponse[
                  'imageUrl']; // Assuming your PHP returns the URL of the uploaded image

              // Step 2: Send the data
              var dataRequest =
                  http.MultipartRequest('POST', Uri.parse(API.saveBrandData));

              dataRequest.fields['brandInfo'] =
                  brandInfoTextEditingController.text.trim();
              dataRequest.fields['brandTitle'] =
                  brandTitleTextEditingController.text.trim();
              dataRequest.fields['brandID'] = brandID;
              dataRequest.fields['sellerUID'] = sellerID;
              dataRequest.fields['thumbnailUrl'] =
                  imageUrl; // Use the returned image URL

              var dataResponse = await dataRequest.send();
              var dataResponseBody = await dataResponse.stream.bytesToString();

              if (dataResponse.statusCode == 200) {
                try {
                  var dataJsonResponse = jsonDecode(dataResponseBody);
                  if (dataJsonResponse['status'] == 'success') {
                    setState(() {
                      uploading = false;
                      brandID =
                          DateTime.now().millisecondsSinceEpoch.toString();
                    });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => HomeScreen()));
                        Fluttertoast.showToast(msg: 'Brand Added Successfully');
                  } else {
                    Fluttertoast.showToast(msg: dataJsonResponse['message']);
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: 'Error parsing data response: $e');
                }
              } else {
                Fluttertoast.showToast(
                    msg:
                        'Data server responded with code: ${dataResponse.statusCode}');
              }
            } else {
              Fluttertoast.showToast(msg: imgJsonResponse['message']);
            }
          } catch (e) {
            Fluttertoast.showToast(
                msg: 'Error parsing image upload response: $e');
          }
        } else {
          Fluttertoast.showToast(
              msg:
                  'Image server responded with code: ${response.statusCode}');
        }
      } else {
        Fluttertoast.showToast(msg: "Please write brand info and brand title.");
      }
    } else {
      Fluttertoast.showToast(msg: "Please choose an image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return imgXFile == null ? defaultScreen() : uploadFormScreen();
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text("Add New Brand"),
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
                Icons.add_photo_alternate_outlined,
                color: Colors.black,
                size: 200,
              ),
              ElevatedButton(
                  onPressed: () {
                    obtainImageDialogBox();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Add New Brand",
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget uploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const SellerSplashScreen()));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: () {
                uploading == true ? null : validateUploadForm();
              },
              icon: const Icon(
                Icons.cloud_upload,
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )),
        ),
        title: const Text("Upload New Brand"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          uploading == true ? linearProgressBar() : Container(),
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
          ListTile(
            leading: const Icon(
              Icons.perm_device_information,
              color: Colors.black,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: brandInfoTextEditingController,
                decoration: const InputDecoration(
                  hintText: "brand info",
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
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.black,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                controller: brandTitleTextEditingController,
                decoration: const InputDecoration(
                  hintText: "brand title",
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.pinkAccent,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  obtainImageDialogBox() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Center(
              child: const Text(
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
                child: Center(
                  child: const Text(
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
                child: Center(
                  child: const Text(
                    "Select image from Gallery",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => UploadBrandsScreen()));
                },
                child: Center(
                  child: const Text(
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

  getImageFromGallery() async {
    Navigator.pop(context);
    imgXFile = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  captureImagewithPhoneCamera() async {
    Navigator.pop(context);
    imgXFile = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {});
  }
}
