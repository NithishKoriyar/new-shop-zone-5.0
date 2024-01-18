import 'package:flutter/material.dart';

class RidersErrorDialog extends StatelessWidget
{
  final String? message;
  const RidersErrorDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
               backgroundColor: Colors.red,
             ),
          onPressed: ()
          {
            Navigator.pop(context);
          },
            child: const Center(
              child: Text("OK"),
            ),
        ),
      ],
    );
  }
}
