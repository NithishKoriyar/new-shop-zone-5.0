import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopzone/rider/riders_model/orders.dart';
import 'package:shopzone/rider/riders_model/rider_items.dart';

class OrderCard extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;
  final Orders model;

  OrderCard({
    this.itemCount,
    this.data,
    this.orderID,
    this.seperateQuantitiesList, 
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == null || data == null || seperateQuantitiesList == null) {
      return Center(child: Text("Data is not available"));
    }

    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (c) => OrderDetailsScreen(orderID: orderID)));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        height: itemCount * 125,
        child: ListView.builder(
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Map<String, dynamic>? itemData = data[index].data() as Map<String, dynamic>?;
            if (itemData == null) {
              return Text("Item data not available");
            }
            Items itemModel = Items.fromJson(itemData);
            return placedOrderDesignWidget(itemModel, context,);
          },
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
