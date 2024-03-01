import 'package:flutter/material.dart';


class NoConnectionPage extends StatefulWidget {
  @override
  State<NoConnectionPage> createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/no-connection.png', // Change to your image path
                width: 300, // Adjust width as needed
                height: 300, // Adjust height as needed
              ),
              // SizedBox(height: 20),
              // Text(
              //   'No Internet Connection',
              //   style: TextStyle(fontSize: 20),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
