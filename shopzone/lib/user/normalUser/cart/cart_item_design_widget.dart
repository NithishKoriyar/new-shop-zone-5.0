import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/normalUser/cart/cart_item_details.dart';
import 'package:shopzone/user/models/cart.dart';

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
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                //image
                Image.network(
                  API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
                  width: 140,
                  height: 120,
                ),

                const SizedBox(
                  width: 6,
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //title
                      Text(
                        widget.model!.itemTitle.toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      //Price: ₹ 12
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

                      const SizedBox(
                        height: 10,
                      ),

                      //Quantity: 4
                      Row(
                        children: [
                          const Text(
                            "Quantity: ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            widget.quantityNumber.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
