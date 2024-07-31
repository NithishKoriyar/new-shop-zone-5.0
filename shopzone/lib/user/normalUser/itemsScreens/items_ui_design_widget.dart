import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/items.dart';
import 'items_details_screen.dart';




// ignore: must_be_immutable
class ItemsUiDesignWidget extends StatefulWidget
{
  Items? model;

  ItemsUiDesignWidget({this.model,});

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

                const SizedBox(height: 1,),

                Text(
                  widget.model!.itemTitle.toString(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 187, 208, 48),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 1,),

                // Text(
                //   widget.model!.itemInfo.toString(),
                //   style: const TextStyle(
                //     color: Colors.black87,
                //     fontSize: 14,
                //   ),
                // ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
