import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/rider/riders_mainScreens/rider_order_details_screen.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_model/rider_items.dart';

class OrderCard extends StatefulWidget {
  Orders? model;
  int? quantityNumber;

  OrderCard({
    this.model,
    this.quantityNumber,
  });
 
  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  
  @override
  
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => OrderDetailsScreen(
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
                  API.foodSellerGetItemsImage + (widget.model!.thumbnailUrl ?? ''),
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
                        height: 4,
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
                           widget.model!.itemQuantity.toString(),
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


Widget placedOrderDesignWidget(Items model, BuildContext context, String quantity) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 120,
    color: Colors.grey[200],
    child: Row(
      children: [
        Image.network(model.thumbnailUrl ?? '', width: 120),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      model.title ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: "Acme",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "₹",
                    style: TextStyle(fontSize: 16.0, color: Colors.blue),
                  ),
                  Text(
                    model.price?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "x ",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    quantity,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 30,
                      fontFamily: "Acme",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
