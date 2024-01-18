import 'package:flutter/material.dart';
import 'package:shopzone/rider/riders_widgets/riders_progress_bar.dart';

class RidersLoadingDialog extends StatelessWidget
{
  final String? message;

  const RidersLoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
     content: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         circularProgress(),
         const SizedBox(height: 10,),
         Text("${message!}Please Wait..."),
       ],
     ),
    );
  }
}
