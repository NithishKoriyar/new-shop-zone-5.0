import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/addressScreens/address_screen.dart';
import 'package:shopzone/user/normalUser/cart/cart_item_details.dart';
import 'package:shopzone/user/models/cart.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shopzone/user/userPreferences/current_user.dart';

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
  final CurrentUser currentUserController = Get.put(CurrentUser());
  int _quantity = 1;
  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantityNumber ?? 1;

    _updatePrice();
  }

  void _updatePrice() {
    setState(() {
      // Assuming sellingPrice is a string that may contain a decimal number.
      widget.model!.totalPrice = (_quantity *
              double.parse(widget.model!.sellingPrice ?? '0'))
          .toInt(); // Convert the result to an integer, if totalPrice is expected to be an integer.
    });
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
      setState(() {
        Navigator.pop(context);
      });
    } else {
      Fluttertoast.showToast(msg: 'Failed to remove item. Please try again.');
    }
  }

  String _calculateDiscount(String originalPrice, String sellingPrice) {
    double original = double.parse(originalPrice);
    double selling = double.parse(sellingPrice);
    double discount = ((original - selling) / original) * 100;
    return "-${discount.toStringAsFixed(0)}%";
  }

  Color colorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.transparent; // Default color if the name doesn't match
    }
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
                          API.getItemsImage +
                              (widget.model!.thumbnailUrl ?? ''),
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

                            Text(
                              widget.model!.colourName.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.model!.sizeName.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              
                              ),
                            ),

                            // Size Selection
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: SingleChildScrollView(
                            //     scrollDirection: Axis.horizontal,
                            //     child: Row(
                            //       children: widget.model!.sizeName?.map((size) {
                            //             return GestureDetector(
                            //               onTap: () {
                            //                 setState(() {
                            //                   selectedSize = size;
                            //                 });
                            //               },
                            //               child: Container(
                            //                 margin: const EdgeInsets.symmetric(
                            //                     horizontal: 5.0),
                            //                 padding: const EdgeInsets.all(10.0),
                            //                 decoration: BoxDecoration(
                            //                   color: selectedSize == size
                            //                       ? Colors.black
                            //                       : Colors.white,
                            //                   border: Border.all(
                            //                     color: Colors.black,
                            //                   ),
                            //                   borderRadius:
                            //                       BorderRadius.circular(5.0),
                            //                 ),
                            //                 child: Text(
                            //                   size,
                            //                   style: TextStyle(
                            //                     color: selectedSize == size
                            //                         ? Colors.white
                            //                         : Colors.blueGrey,
                            //                     fontWeight: FontWeight.bold,
                            //                   ),
                            //                 ),
                            //               ),
                            //             );
                            //           }).toList() ??
                            //           [],
                            //     ),
                            //   ),
                            // ),

                            const SizedBox(height: 4),

                            // Color Selection
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Row(
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: [
                            //       Text(
                            //         'Color: ',
                            //         style: const TextStyle(
                            //           fontSize: 17,
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //       Text(
                            //         selectedColor ?? '',
                            //         style: const TextStyle(
                            //           fontSize: 17,
                            //           color: Colors.black,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //       SizedBox(width: 5),
                            //       Expanded(
                            //         child: SingleChildScrollView(
                            //           scrollDirection: Axis.horizontal,
                            //           child: Row(
                            //             children: widget.model!.colourName
                            //                     ?.toSet()
                            //                     .map((color) {
                            //                   return GestureDetector(
                            //                     onTap: () {
                            //                       setState(() {
                            //                         selectedColor = color;
                            //                       });
                            //                     },
                            //                     child: Container(
                            //                       margin: const EdgeInsets
                            //                           .symmetric(
                            //                           horizontal: 5.0),
                            //                       padding:
                            //                           const EdgeInsets.all(1.0),
                            //                       decoration: BoxDecoration(
                            //                         shape: BoxShape.rectangle,
                            //                         border: Border.all(
                            //                           color: selectedColor ==
                            //                                   color
                            //                               ? Colors.black
                            //                               : Colors.transparent,
                            //                           width: 0.1,
                            //                         ),
                            //                       ),
                            //                       child: CircleAvatar(
                            //                         backgroundColor:
                            //                             colorFromName(color),
                            //                         radius: 15,
                            //                       ),
                            //                     ),
                            //                   );
                            //                 }).toList() ??
                            //                 [],
                            //           ),
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            const SizedBox(height: 8),

                            // Price Display
                            Row(
                              children: [
                                Text(
                                  "₹${widget.model!.sellingPrice}", // Selling price in bold green
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 10), // Space between prices
                                if (widget.model!.price != null)
                                  Text(
                                    "₹${widget.model!.price}", // Original price with strike-through
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                SizedBox(
                                    width:
                                        10), // Space between prices and discount
                                if (widget.model!.price != null &&
                                    widget.model!.sellingPrice != null)
                                  Text(
                                    _calculateDiscount(
                                        widget.model!.price!,
                                        widget.model!.sellingPrice!
                                            as String), // Discount percentage
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.green,
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
                          removeItemFromCart(
                              currentUserController.user.user_id.toString(),
                              widget.model!.itemID.toString());
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                        label:
                            Text("Remove", style: TextStyle(color: Colors.red)),
                      ),

                      // Add to Wishlist Button
                      TextButton.icon(
                        onPressed: () {
                          // Add to wishlist logic here
                        },
                        icon: Icon(Icons.favorite_border, color: Colors.pink),
                        label: Text("Wishlist",
                            style: TextStyle(color: Colors.pink)),
                      ),

                      // Buy Now Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => AddressScreen(
      model: widget.model,
      quantity: _quantity,
      price: widget.model!.price,
      sellingPrice: widget.model!.sellingPrice,
      totalPrice: widget.model!.totalPrice.toString(),
      calculateDiscount: _calculateDiscount(widget.model!.price!, widget.model!.sellingPrice!),
    ),
  ),
);
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
}
