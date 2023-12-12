import 'package:flutter/material.dart';
import 'package:shopzone/foodSeller/itemsScreens/food_seller_items_details_screen.dart';
import 'package:shopzone/foodSeller/models/food_seller_items.dart';
import '../../api_key.dart';

// ignore: must_be_immutable
class ItemsUiDesignWidget extends StatefulWidget
{
  Items? model;
  BuildContext? context;

  ItemsUiDesignWidget({this.model, this.context,});

  @override
  State<ItemsUiDesignWidget> createState() => _ItemsUiDesignWidgetState();
}




class _ItemsUiDesignWidgetState extends State<ItemsUiDesignWidget>
{
  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemsDetailsScreen(
          model: widget.model,
        )));
      },
      child: Card(
        elevation: 10,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 270,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [

                const SizedBox(height: 2,),

                Text(
                  widget.model!.itemTitle.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 3,
                  ),
                ),                                                                                                                         

                const SizedBox(height: 2,),
//API.getItemsImage + (widget.model!.thumbnailUrl ?? ''),
                Image.network(
                  API.foodSellerGetItemsImage + (widget.model!.thumbnailUrl ?? ''),
                  // widget.model!.thumbnailUrl.toString(),
                  height: 220,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 4,),

                Text(
                  widget.model!.itemInfo.toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
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
