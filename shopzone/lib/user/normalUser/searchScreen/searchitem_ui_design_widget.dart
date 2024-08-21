import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_details_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class SearchItemsUiDesignWidget extends StatefulWidget {
  Items? model;

  SearchItemsUiDesignWidget({
    this.model,
  });

  @override
  State<SearchItemsUiDesignWidget> createState() =>
      _SearchItemsUiDesignWidgetState();
}

class _SearchItemsUiDesignWidgetState extends State<SearchItemsUiDesignWidget> {
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String?> imageUrls = [
      widget.model!.thumbnailUrl,
      widget.model!.secondImageUrl,
      widget.model!.thirdImageUrl,
      widget.model!.fourthImageUrl,
      widget.model!.fifthImageUrl,
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ItemsDetailsScreen(
              model: widget.model,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Hero(
                    tag: API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
                    child: Container(
                      height: 80,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          if (imageUrls[index] != null) {
                            return Image.network(
                              API.getItemsImage + (imageUrls[index] ?? ''),
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Icon(
                                  Icons.error,
                                  color: Colors.red,
                                );
                              },
                            );
                          } else {
                            return Container(
                              height: 80,
                              color: Colors.grey[300],
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                  height: 80,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  widget.model!.itemTitle.toString(),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
