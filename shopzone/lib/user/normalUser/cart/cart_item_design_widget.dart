import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/addressScreens/address_screen.dart';
import 'package:shopzone/user/normalUser/cart/cart_item_details.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:shopzone/user/normalUser/wishlist/wishlist_screen.dart';
import 'package:http/http.dart' as http;
// ignore: must_be_immutable
class CartItemDesignWidget extends StatefulWidget {
  Carts? model;
  int? quantityNumber;
  

  CartItemDesignWidget({
    this.model,
    this.quantityNumber,
  });

  @override
  State<CartItemDesignWidget> createState() => _CartItemDesignWidgetState();
}

class _CartItemDesignWidgetState extends State<CartItemDesignWidget> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantityNumber ?? 1;
  }

  void _updatePrice() {
    setState(() {
      widget.model!.totalPrice = _quantity * int.parse(widget.model!.price ?? '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
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
        shadowColor: Colors.white54,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with Quantity Dropdown under it
                    Column(
                      children: [
                        Image.network(
                          API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
                          width: 140,
                          height: 120,
                        ),
                        const SizedBox(height: 5),
                        // Quantity Dropdown directly under the image
                        Row(
                          children: [
                            const Text(
                              "Qty: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            DropdownButton<int>(
                              value: _quantity,
                              items: List.generate(10, (index) => index + 1)
                                  .map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  _quantity = newValue ?? 1;
                                  _updatePrice();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(width: 6),

                    // Product Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Item Title
                            Text(
                              widget.model!.itemTitle.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 2),

                            // Size and Color
                            Row(
                              children: [
                                const Text(
                                  'Size: ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    widget.model!.sizeName?.join(", ") ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Row(
                            //   children: [
                            //     const Text(
                            //       "Color: ",
                            //       style: TextStyle(
                            //         color: Colors.black,
                            //         fontSize: 15,
                            //       ),
                            //     ),
                            //     Flexible(
                            //       child: Text(
                            //         widget.model!.colourName?.join(", ") ?? 'N/A',
                            //         style: const TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 15,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            const SizedBox(height: 8),

                            // Price
                            Row(
                              children: [
                                const Text(
                                  "Price: ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                const Text(
                                  "₹ ",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  widget.model!.price.toString(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Total Price
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Total Price : ₹ " +
                                    (widget.model!.totalPrice ?? 0).toString(),
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Remove Button
                      TextButton.icon(
                        onPressed: () {
                          // Logic to remove item from cart
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text("Remove", style: TextStyle(color: Colors.red)),
                      ),

                      // Add to Wishlist Button
                      TextButton.icon(
                        onPressed: () {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (c) => WishListScreen()));
            },
                        icon: Icon(Icons.favorite_border, color: Colors.pink),
                        label: Text("Wishlist", style: TextStyle(color: Colors.pink)),
                      ),

                      // Buy Now Button
                      ElevatedButton(
                         onPressed: () {
              Navigator.push(
                
                  context, MaterialPageRoute(builder: (c) => AddressScreen(
                    model: widget.model,
                    )));
            },
                        child: Text("Buy This Now"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
   Future<void> removeItemFromCart(String userID, String itemID) async {
    final response = await http.post(
      Uri.parse(API.deleteItemFromCart),
      body: {
        'userId': userID,
        'itemId': itemID,
      },
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Item removed successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Failed to remove item. Please try again.');
    }
  }
}
