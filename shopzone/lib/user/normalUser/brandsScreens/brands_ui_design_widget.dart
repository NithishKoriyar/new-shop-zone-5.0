
import 'package:flutter/material.dart';
import 'package:shopzone/api_key.dart';
import 'package:shopzone/user/models/brands.dart';
import 'package:shopzone/user/normalUser/itemsScreens/items_screen.dart';



// ignore: must_be_immutable
class BrandsUiDesignWidget extends StatefulWidget
{
  Brands? model;

  BrandsUiDesignWidget({this.model,});

  @override
  State<BrandsUiDesignWidget> createState() => _BrandsUiDesignWidgetState();
}




class _BrandsUiDesignWidgetState extends State<BrandsUiDesignWidget>
{
  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> ItemsScreen(
          model: widget.model,
        )));
      },
      child: Card(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
             height: 270,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    API.brandImage + (widget.model!.thumbnailUrl ?? ''),
                    // widget.model!.thumbnailUrl.toString(),
                    // height: 220,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 1,),

                Text(
                  widget.model!.brandTitle.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 3,
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
