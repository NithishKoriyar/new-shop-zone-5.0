import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'items_details_screen.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ItemsUiDesignWidget extends StatefulWidget {
  Items? model;

  ItemsUiDesignWidget({
    this.model,
  });

  @override
  State<ItemsUiDesignWidget> createState() => _ItemsUiDesignWidgetState();
}

class _ItemsUiDesignWidgetState extends State<ItemsUiDesignWidget> {
  bool isInWishlist = false;
  @override
  void initState() {
    super.initState();
    checkIfInWishlist();
  }

  void checkIfInWishlist() async {
    // Simulate fetching wishlist state from the server
    final response = await http.post(
      Uri.parse(API.checkWishlist),
      body: {
        'userId': '1', // Replace with dynamic userId
        'itemId': widget.model!.itemID.toString(),
      },
    );

    if (response.statusCode == 200 && response.body == 'true') {
      setState(() {
        isInWishlist = true;
      });
    }
  }

  void toggleWishlist() async {
    final response = await http.post(
      Uri.parse(isInWishlist ? API.removeFromWishlist : API.addToWishlist),
      body: {
        'userId': '1', // Replace with dynamic userId
        'itemId': widget.model!.itemID.toString(),
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: isInWishlist ? 'Removed from wishlist' : 'Added to wishlist');
      setState(() {
        isInWishlist = !isInWishlist;
      });
    } else {
      Fluttertoast.showToast(msg: 'Action failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => ItemsDetailsScreen(
                      model: widget.model,
                    )));
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
                    child: Image.network(
                      API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
                      //widget.model!.thumbnailUrl.toString(),
                      height: 220,
                      fit: BoxFit.cover,
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
                    fontSize: 20,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  widget.model!.itemInfo.toString(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: toggleWishlist,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
